module Chess.AI where

import Chess.Base
import Chess.Game
import Chess.MoveGen

evalGame :: RegularGame -> Player -> Double
evalGame = evalPosition . placement

evalPosition              :: RegularBoardRepresentation -> Player -> Double
evalPosition position ply = foldr ((+) . pieceValue) 0 $ foldr (++) [] position where

  pieceValue :: Square -> Double
  pieceValue (Square (Just (Piece Pawn owner)) _)   | owner == ply = 100
                                                    | otherwise    = -100
  pieceValue (Square (Just (Piece Knight owner)) _) | owner == ply = 300
                                                    | otherwise    = -300
  pieceValue (Square (Just (Piece Bishop owner)) _) | owner == ply = 300
                                                    | otherwise    = -300
  pieceValue (Square (Just (Piece Rook owner)) _)   | owner == ply = 300
                                                    | otherwise    = -300
  pieceValue (Square (Just (Piece Queen owner)) _)  | owner == ply = 300
                                                    | otherwise    = -300
  pieceValue _ = 0
