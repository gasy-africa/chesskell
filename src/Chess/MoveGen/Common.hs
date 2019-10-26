module Chess.MoveGen.Common where

import Chess.Base
import Chess.Board
import Chess.Bitboard

import Data.Maybe

data Ray = N | NE | E | SE | S | SW | W | NW deriving(Eq, Show)

rayToOffsets :: Ray -> (Int, Int)
rayToOffsets N = (0, 1)
rayToOffsets NE = (1, 1)
rayToOffsets E = (1, 0)
rayToOffsets SE = (1, -1)
rayToOffsets S = (0, -1)
rayToOffsets SW = (-1, -1)
rayToOffsets W = (-1, 0)
rayToOffsets NW = (-1, 1)

rayGeneratorFor :: Ray -> (Int, Int) -> Bitboard
rayGeneratorFor N = northRay
rayGeneratorFor NE = northEastRay
rayGeneratorFor E = eastRay
rayGeneratorFor SE = southEastRay
rayGeneratorFor S = southRay
rayGeneratorFor SW = southWestRay
rayGeneratorFor W = westRay
rayGeneratorFor NW = northWestRay

liftOp :: (a -> b -> c) -> b -> [a] -> [c]
liftOp f c xs = (flip f) c <$> xs

potentialOffsetMoves              :: [(Int, Int)] -> BitboardRepresentation -> Coordinate -> [Move]
potentialOffsetMoves offsets bb c = fmap destinationToMove . filter canMoveToDestination . filter isOnBoard $ fmap (c `offsetBy`) offsets
  where canMoveToDestination = (flip (unoccupiedByAlly bb) (fmap pieceOwner $ bitboardPieceAt bb c))
        destinationToMove x = Move { moveFrom = c
                                   , moveTo = x
                                   , moveType = determineMoveType bb c x
                                   , movePromoteTo = Nothing
                                   }

potentialRayMoves              :: BitboardRepresentation -> Player -> Coordinate -> [Ray] -> [Move]
potentialRayMoves b ply c rays = toLegalMoves $ foldr bitboardUnion emptyBitboard $ potentialRayMoves' occupancy ply c <$> rays
  where
    occupancy = totalOccupancy b
    toLegalMoves = filter selfCaptures
      . fmap destinationToMove
      . bitboardToCoordinates
    selfCaptures move = moveType move /= Capture || (moveType move == Capture && (pieceOwner <$> (bitboardPieceAt b (moveTo move))) /= Just ply)
    destinationToMove dest = Move { moveFrom = c
                                  , moveTo = dest
                                  , moveType = determineMoveType b c dest
                                  , movePromoteTo = Nothing }

potentialRayMoves' :: Bitboard -> Player -> Coordinate -> Ray -> Bitboard
potentialRayMoves' occupancy ply c r | r == E || r == N || r == NE || r == NW = potentialPositiveRayMoves occupancy ply c r
                             | otherwise = potentialNegativeRayMoves occupancy ply c r

potentialPositiveRayMoves :: Bitboard -> Player -> Coordinate -> Ray -> Bitboard
potentialPositiveRayMoves occupancy ply c r = unobstructedRay `bitboardXOR` rayFromBlocker
    where unobstructedRay = rayGeneratorFor r (coordinateToIndices c)
          blocker = bitscanForward $ unobstructedRay `bitboardIntersect` occupancy
          rayFromBlocker = rayGeneratorFor r (squareIndexToIndices blocker)

potentialNegativeRayMoves :: Bitboard -> Player -> Coordinate -> Ray -> Bitboard
potentialNegativeRayMoves occupancy ply c r = unobstructedRay `bitboardXOR` rayFromBlocker
    where unobstructedRay = rayGeneratorFor r (coordinateToIndices c)
          blocker = bitscanReverse $ unobstructedRay `bitboardIntersect` occupancy
          rayFromBlocker = rayGeneratorFor r (squareIndexToIndices blocker)

determineMoveType              :: BitboardRepresentation -> Coordinate -> Coordinate -> MoveType
determineMoveType b _ to       | bitboardIsOccupied b to = Capture
                               | otherwise = Standard

determinePieceOwner :: RegularBoardRepresentation -> Coordinate -> Maybe Player
determinePieceOwner b c = fmap pieceOwner $ pieceAt b c

isBlocked                       :: RegularBoardRepresentation -> Move -> Bool
isBlocked b Move { moveFrom = from
                 , moveTo = to }  = not $ to `elem` (validMoves $ alongRay (from, to)) where

  validMoves    :: [Coordinate] -> [Coordinate]
  validMoves cs = validMoves' cs False

  validMoves'                :: [Coordinate] -> Bool -> [Coordinate]
  validMoves' (c:cs) blocked | blocked == True = []
                             | otherwise       = case (fmap pieceOwner $ pieceAt b c) of
                                                   Nothing                -> c:validMoves' cs False
                                                   (Just owner) -> if ((Just owner) == (fmap pieceOwner $ pieceAt b from))
                                                                               then []
                                                                               else c:validMoves' cs True

alongRay            :: (Coordinate, Coordinate) -> [Coordinate]
alongRay (from, to) = filter (\x -> coordinateEuclideanDistance from x <= coordinateEuclideanDistance from to)
                    $ filter isOnBoard
                    $ fmap (from `offsetBy`)
                    $ scaleBy <$> [1..7] <*> [rayFromMove (from, to)]

rayFromMove                                    :: (Coordinate, Coordinate) -> (Int, Int)
rayFromMove (Coordinate f r, Coordinate f' r') | fromEnum f' > fromEnum f && r' > r = (1,1)
                                               | fromEnum f' > fromEnum f && r' < r = (1,-1)
                                               | fromEnum f' > fromEnum f && r' == r = (1,0)
                                               | fromEnum f' < fromEnum f && r' > r = (-1,1)
                                               | fromEnum f' < fromEnum f && r' < r = (-1,-1)
                                               | fromEnum f' < fromEnum f && r' == r = (-1,0)
                                               | fromEnum f' == fromEnum f && r' > r = (0,1)
                                               | fromEnum f' == fromEnum f && r' < r = (0,-1)
                                               | fromEnum f' == fromEnum f && r' == r = (0,0)

coordinateEuclideanDistance                                       :: Coordinate -> Coordinate -> Int
coordinateEuclideanDistance (Coordinate cx y) (Coordinate cx' y') = ((x' - x) ^ 2) + ((y' - y) ^ 2) where
  x' = fromEnum cx' - fromEnum 'a'
  x  = fromEnum cx - fromEnum 'a'

offsetBy                          :: Coordinate -> (Int, Int) -> Coordinate
offsetBy (Coordinate f r) (df,dr) = Coordinate (toEnum $ fromEnum f + df) (r + dr)

scaleBy                           :: Int -> (Int, Int) -> (Int, Int)
scaleBy s (x,y)                   = (x*s, y*s)

unoccupied     :: RegularBoardRepresentation -> Coordinate -> Bool
unoccupied b c = isNothing $ pieceAt b c

unoccupiedByAlly         :: BitboardRepresentation -> Coordinate -> Maybe Player -> Bool
unoccupiedByAlly b c ply | isNothing targetOwner = True
                         | ply /= targetOwner = True
                         | ply == targetOwner = False where
  targetPiece = bitboardPieceAt b c
  targetOwner = pieceOwner <$> targetPiece
