module Chess.Game where

import Control.Applicative
import Control.Monad.State.Lazy

import Chess.Base
import Chess.MoveGen

import Data.Maybe

doMove                                             :: Maybe Piece -> Move -> State RegularGame Bool
doMove promoteTo move@Move { moveType = movetype } | movetype == Standard  = doStandardMove move
                                                   | movetype == Capture   = doStandardMove move
                                                   | movetype == Castle    = doCastle move
                                                   | movetype == Promotion = doPromotion promoteTo move
                                                   | movetype == EnPassant = doEnPassant move

makeStandardMove                                    :: RegularGame -> Move -> Maybe RegularGame
makeStandardMove game move@Move { moveFrom = from } | not $ move `elem` pseudoLegalMoves game = Nothing
                                                    | not $ (pieceOwner <$> (pieceOn $ (squareAt (placement game) from))) == (Just $ activeColor game) = Nothing
                                                    | isChecked game { placement = positionAfterMove (placement game) move } = Nothing
                                                    | otherwise = Just $ game { activeColor = opponent (activeColor game)
                                                                              , placement   = movePiece (placement game) (pieceOn $ (squareAt (placement game) from)) move
                                                                              }


doStandardMove                              :: Move -> State RegularGame Bool
doStandardMove move@Move { moveFrom = from } = do
  game <- get
  case (makeStandardMove game move) of
    (Just nextState) -> put nextState >> return True
    _                -> return False

doCastle                              :: Move -> State RegularGame Bool
doCastle move@Move { moveFrom = from
                   , moveTo   = to }  | from == Coordinate 'e' 1 && to == Coordinate 'g' 1 = doWhiteKingsideCastle
                                      | from == Coordinate 'e' 1 && to == Coordinate 'c' 1 = doWhiteQueensideCastle
                                      | from == Coordinate 'e' 8 && to == Coordinate 'g' 8 = doBlackKingsideCastle
                                      | from == Coordinate 'e' 8 && to == Coordinate 'c' 8 = doBlackQueensideCastle where

  doWhiteKingsideCastle :: State RegularGame Bool
  doWhiteKingsideCastle = doCastle' [Coordinate 'f' 1, Coordinate 'g' 1] disableWhiteCastles
    Move { moveFrom = Coordinate 'h' 1
         , moveTo   = Coordinate 'f' 1
         , moveType = Castle
         }

  doWhiteQueensideCastle :: State RegularGame Bool
  doWhiteQueensideCastle = doCastle' [Coordinate 'd' 1, Coordinate 'c' 1] disableWhiteCastles
    Move { moveFrom = Coordinate 'a' 1
         , moveTo   = Coordinate 'd' 1
         , moveType = Castle
         }

  doBlackKingsideCastle :: State RegularGame Bool
  doBlackKingsideCastle = doCastle' [Coordinate 'f' 8, Coordinate 'g' 8] disableBlackCastles
    Move { moveFrom = Coordinate 'h' 8
         , moveTo   = Coordinate 'f' 8
         , moveType = Castle
         }

  doBlackQueensideCastle :: State RegularGame Bool
  doBlackQueensideCastle = doCastle' [Coordinate 'd' 8, Coordinate 'c' 8] disableBlackCastles
    Move { moveFrom = Coordinate 'a' 8
         , moveTo   = Coordinate 'd' 8
         , moveType = Castle
         }

  disableWhiteCastles :: CastleRights -> CastleRights
  disableWhiteCastles (CastleRights _ boo _ booo) = CastleRights False boo False booo

  disableBlackCastles :: CastleRights -> CastleRights
  disableBlackCastles (CastleRights woo _ wooo _) = CastleRights woo False wooo False

  makeCastle :: RegularGame -> [Coordinate] -> (CastleRights -> CastleRights) -> Move -> Maybe RegularGame
  makeCastle game castlingSquares fUpdateRights rookMove@Move { moveFrom = rookFrom } | isChecked game { placement = positionAfterMove (positionAfterMove (placement game) move) rookMove } = Nothing
                                                                                      | not $ all (not . isAttacked game) castlingSquares = Nothing
                                                                                      | otherwise = Just $ game { activeColor = opponent (activeColor game)
                                                                                                                , castlingRights = fUpdateRights (castlingRights game)
                                                                                                                , placement = movePiece (movePiece (placement game) (pieceOn $ squareAt (placement game) from) move) (pieceOn $ squareAt (placement game) rookFrom) rookMove
                                                                                                                }

  doCastle' :: [Coordinate] -> (CastleRights -> CastleRights) -> Move -> State RegularGame Bool
  doCastle' castlingSquares fupdaterights rookMove = do
    game <- get
    case (makeCastle game castlingSquares fupdaterights rookMove) of
        (Just nextState) -> put nextState >> return True
        _                -> return False

makePromotion :: RegularGame -> Maybe Piece -> Move -> Maybe RegularGame
makePromotion game p move | isChecked game { placement = positionAfterMove (placement game) move } = Nothing
                          | otherwise = Just $ game { activeColor = opponent (activeColor game)
                                                    , placement   = movePiece (placement game) p move
                                                    }

doPromotion :: Maybe Piece -> Move -> State RegularGame Bool
doPromotion p move = do
  game <- get
  case (makePromotion game p move) of
      (Just nextState) -> put nextState >> return True
      _                -> return False

doEnPassant   :: Move -> State RegularGame Bool
doEnPassant m@Move { moveTo = Coordinate f r
                     , moveFrom = from } = do
  game <- get
  if (m `elem` pseudoLegalMoves game) && (not $ isChecked game { placement = positionAfterMove (placement game) m })
    then do let position = placement game
            let originalPiece = pieceOn $ squareAt position from
            let rankOffset = if fmap pieceOwner originalPiece == Just White then (-1) else 1
            put $ game { activeColor = opponent (activeColor game) 
                       , enPassantSquare = Nothing }

            doMovePiece originalPiece m
            updateSquare (Coordinate f (r+rankOffset)) Nothing

            return True
    else return False

addPiece                        :: RegularBoardRepresentation -> Maybe Piece -> Coordinate -> RegularBoardRepresentation
addPiece b p c@(Coordinate f r) = newPlacement where
  newPlacement = fst splitBoard ++ [fst splitRank ++ [Square p c] ++ (tail . snd $ splitRank)] ++ (tail . snd $ splitBoard)
  splitBoard = splitAt (r - 1) b
  splitRank = splitAt (fromEnum f - fromEnum 'a') targetRank
  targetRank = head . snd $ splitBoard

doMovePiece     :: Maybe Piece -> Move -> State RegularGame ()
doMovePiece p m = do
  game <- get
  let position = placement game
  put $ game { placement = movePiece position p m }

movePiece :: RegularBoardRepresentation -> Maybe Piece -> Move -> RegularBoardRepresentation
movePiece position piece Move { moveFrom = from
                              , moveTo   = to } = addPiece (addPiece position Nothing from) piece to

positionAfterMove :: RegularBoardRepresentation -> Move -> RegularBoardRepresentation
positionAfterMove position move@Move { moveFrom = from } = movePiece position (pieceOn $ (squareAt position from)) move

-- TODO: extract non-monadic operations
updateSquare     :: Coordinate -> Maybe Piece -> State RegularGame ()
updateSquare c p = do
  game <- get
  let position = placement game
  put $ game { placement = addPiece position p c }

isCheckmate          :: RegularGame -> Player -> Bool
isCheckmate game ply = null $ filter (\x -> pieceIsOwnedByPly x && (not $ isChecked game { placement = positionAfterMove (placement game) x })) $ pseudoLegalMoves game where

  pieceIsOwnedByPly :: Move -> Bool
  pieceIsOwnedByPly Move { moveFrom = from } = (pieceOwner <$> (pieceOn $ (squareAt (placement game) from))) == (Just ply)

isStalemate          :: RegularGame -> Player -> Bool
isStalemate game ply = (not $ isChecked game) && (null $ filter (\x -> pieceIsOwnedByPly x && (not $ isChecked game { placement = positionAfterMove (placement game) x })) $ pseudoLegalMoves game) where

  pieceIsOwnedByPly :: Move -> Bool
  pieceIsOwnedByPly Move { moveFrom = from } = (pieceOwner <$> (pieceOn $ (squareAt (placement game) from))) == (Just ply)

isAttacked :: RegularGame -> Coordinate -> Bool
isAttacked game sq = isQueenChecking || isRookChecking || isBishopChecking || isKnightChecking || isPawnChecking || isKingChecking where

  nextState = (placement game)

  activePly = (activeColor game)

  isChecking            :: PieceType -> (RegularGame -> Coordinate -> [Move]) -> Bool
  isChecking pt movegen = not
                        $ null
                        $ filter (\x -> ((== Capture) $ moveType x) && ((== pt) . fromJust $ pieceType <$> (pieceOn . squareAt nextState $ moveTo x)))
                        $ movegen (game { placement = addPiece nextState (Just (Piece pt activePly)) sq }) sq

  isQueenChecking :: Bool
  isQueenChecking = isChecking Queen potentialQueenMoves

  isRookChecking :: Bool
  isRookChecking = isChecking Rook potentialRookMoves

  isBishopChecking :: Bool
  isBishopChecking = isChecking Bishop potentialBishopMoves

  isKnightChecking :: Bool
  isKnightChecking = isChecking Knight potentialKnightMoves

  -- TODO: do we need to consider en passant? I think not.
  isPawnChecking :: Bool
  isPawnChecking = isChecking Pawn potentialPawnMoves

  -- TODO: do we need to consider castling? I think not.
  isKingChecking :: Bool
  isKingChecking = isChecking King potentialKingMoves

isChecked      :: RegularGame -> Bool
isChecked game = isAttacked game (kingSquare (activeColor game)) where

  kingSquare     :: Player -> Coordinate
  kingSquare ply = location $ head $ filter ((== Just (Piece King ply)) . pieceOn) $ foldr (++) [] (placement game)
