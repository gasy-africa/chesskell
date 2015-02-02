{-# LANGUAGE OverloadedStrings #-}

module Main where

import Data.Aeson.Encode
import Data.Aeson.Types

import Chess.AI
import Chess.Base
import Chess.FenParser
import Chess.Game
import Chess.MoveGen

import Control.Monad
import Control.Monad.Trans

import qualified Data.ByteString.Char8 as C
import Data.Maybe

import Happstack.Server
import Happstack.Server.Types

import System.Environment

import Text.Parsec

data GameStatus = InProgress | WhiteWin | BlackWin | Stalemate

data JsonMove = JsonMove
  { fenString :: String
  , jsonMoveFrom  :: String
  , jsonMoveTo    :: String
  , jsonMoveSuccessful :: Bool
  , jsonMoveGameStatus :: GameStatus
  }

instance ToJSON JsonMove where
  toJSON (JsonMove fen from to successful status) = object ["fen" .= fen, "from" .= from, "to" .= to, "successful" .= successful, "status" .= status]

instance ToJSON GameStatus where
  toJSON InProgress = "*"
  toJSON WhiteWin = "1-0"
  toJSON BlackWin = "0-1"
  toJSON Stalemate = "1/2-1/2"

coordPairToMove :: RegularGame -> Coordinate -> Coordinate -> [Move]
coordPairToMove game from to = filter (\move -> (moveFrom move == from) && (moveTo move == to)) $ pseudoLegalMoves game

determineGameStatus :: RegularGame -> GameStatus
determineGameStatus g = case ((isCheckmate g (activeColor g)), (isStalemate g (activeColor g))) of
                          (True, _) -> if (activeColor g == White) then BlackWin else WhiteWin
                          (False, True) -> Stalemate
                          (False, False) -> InProgress

requestMoveHandler :: ServerPart Response
requestMoveHandler = do

  req <- askRq

  decodeBody (defaultBodyPolicy "/tmp/" 4096 4096 4096)

  fenString <- look "fen"

  let position = either (const undefined) id $ parseFen "" fenString

  let chosenAIMove = decideOnMove (activeColor position) position
  let chosenAIMoveFrom = case (moveFrom chosenAIMove) of
                           Coordinate f r -> return f ++ show r
  let chosenAIMoveTo = case (moveTo chosenAIMove) of
                           Coordinate f r -> return f ++ show r

  let positionAfterAIMove = fromJust $ makeMoveFrom position chosenAIMove

  let gameStatus = determineGameStatus positionAfterAIMove

  ok (toResponseBS (C.pack "application/json") $ encode (JsonMove (toFEN positionAfterAIMove) chosenAIMoveFrom chosenAIMoveTo True gameStatus))

makeMoveHandler :: ServerPart Response
makeMoveHandler = do

  req <- askRq

  decodeBody (defaultBodyPolicy "/tmp/" 4096 4096 4096)

  fenString <- look "fen"
  jsonMoveFrom  <- look "from"
  jsonMoveTo    <- look "to"

  let position = either (const undefined) id $ parseFen "" fenString

  let fromCoord = either (const $ Coordinate 'a' 1) fromJust $ runParser enPassantSquareParser (FenParserState $ Coordinate 'a' 8) "" (jsonMoveFrom ++ " ")
  let toCoord = either (const $ Coordinate 'a' 1) fromJust $ runParser enPassantSquareParser (FenParserState $ Coordinate 'a' 8) "" (jsonMoveTo ++ " ")

  let plyMove = case (coordPairToMove position fromCoord toCoord) of
                  [] -> Nothing
                  xs -> Just $ head (coordPairToMove position fromCoord toCoord)

  case plyMove of
    Nothing -> ok (toResponseBS (C.pack "application/json") $ encode (JsonMove (toFEN position) "" "" False (determineGameStatus position)))
    Just m -> do
      let plyMoveFrom = case (moveFrom m) of
                               Coordinate f r -> return f ++ show r
      let plyMoveTo = case (moveTo m) of
                               Coordinate f r -> return f ++ show r

      let positionAfterPlayerMove = makeMoveFrom position m

      let response = case positionAfterPlayerMove of
                       Nothing -> ok (toResponseBS (C.pack "application/json") $ encode (JsonMove (toFEN position) plyMoveFrom plyMoveTo False (determineGameStatus position)))
                       Just newPosition -> ok (toResponseBS (C.pack "application/json") $ encode (JsonMove (toFEN newPosition) plyMoveFrom plyMoveTo True (determineGameStatus newPosition)))

      response


main :: IO ()
main = do
  envPort <- getEnv "PORT"
  simpleHTTP (nullConf { port = read envPort })
    $ msum [ dir "makemove" $ do method POST
                                 makeMoveHandler
           , dir "requestmove" $ do method POST
                                    requestMoveHandler
           , dir "js" $ serveDirectory DisableBrowsing ["index.html"] "cheskell/js"
           , dir "css" $ serveDirectory DisableBrowsing ["index.html"] "cheskell/css"
           , serveFile (guessContentTypeM mimeTypes) "cheskell/index.html"
           ]
