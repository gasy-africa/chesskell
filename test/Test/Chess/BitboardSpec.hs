module Test.Chess.BitboardSpec where

import Chess.Base
import Chess.Bitboard

import Control.Applicative

import Data.Int
import Data.Word

import Test.Hspec
import Test.Placements
import Test.QuickCheck
import Test.QuickCheck.Arbitrary
import Test.Util

rankAndFileIndices :: Gen (Int, Int)
rankAndFileIndices = do
  ri  <- ranks
  fi  <- files
  return (ri, fi)

ranks :: Gen Int
ranks = choose (0, 7)

files :: Gen Int
files = choose (0, 7)

diagonals :: Gen Int
diagonals = choose (-7, 7)

antiDiagonals :: Gen Int
antiDiagonals = choose (0, 14)

bitboards :: Gen Bitboard
bitboards = do
  w <- choose (minBound :: Word64, maxBound :: Word64)
  return $ Bitboard w

bitboardsAnd :: Gen a -> Gen (Bitboard, a)
bitboardsAnd gen = do
  bitboard <- bitboards
  a <- gen
  return (bitboard, a)


spec :: Spec
spec = describe "bitboard" $ do

  describe "integrations with Base" $ do
    it "can convert Coordinates to 0-based (rank, file) indices" $ do
      forAll coords (\c@(Coordinate f r) -> coordinateToIndices c == (r - 1, fromEnum f - 97))

    it "can convert 0-based (rank, file) indices to Coordinates" $ do
      forAll rankAndFileIndices (\(r, f) -> indicesToCoordinate (r, f) == (Coordinate (toEnum $ f + 97) (r + 1)))

    it "can convert (rank, file) indices to a single square index from [0..63]" $ do
      forAll rankAndFileIndices (\(r, f) -> indicesToSquareIndex (r, f) == 8 * r + f)

    it "can convert single square indices to (rank, file) indices" $ do
      forAll rankAndFileIndices (\(r, f) -> squareIndexToIndices (8 * r + f) == (r, f))

  describe "formatting" $ do
    it "is showable" $ do
      show (Bitboard 9820426766351346249) `shouldBe` "\n. . . 1 . . . 1\n1 . . 1 . . 1 .\n. 1 . 1 . 1 . .\n. . 1 1 1 . . .\n1 1 1 . 1 1 1 1\n. . 1 1 1 . . .\n. 1 . 1 . 1 . .\n1 . . 1 . . 1 .\n"

  describe "representation" $ do
    {--
    . . . . . . . 1
    . . . . . . 1 .
    . . . . . 1 . .
    . . . . 1 . . .
    . . . 1 . . . .
    . . 1 . . . . .
    . 1 . . . . . .
    1 . . . . . . .
    --}
    it "uses little-endian rank-file mapping" $ do
      isOccupied (Bitboard 9241421688590303745) (0 :: Int) && isOccupied (Bitboard 9241421688590303745) (63 :: Int) `shouldBe` True

    it "has a squareIndex defined in terms of a rankIndex and a fileIndex" $ do
      forAll (bitboardsAnd rankAndFileIndices) $ (\(bitboard, (ri, fi)) -> (isOccupied bitboard $ 8 * ri + fi) == isOccupied bitboard (ri, fi))

    it "can be indexed by Coordinate" $ do
      forAll (bitboardsAnd coords) $ (\(bitboard, c@(Coordinate f r)) -> (isOccupied bitboard c) == isOccupied bitboard (coordinateToIndices c))

  describe "setwise operations" $ do
    {--
    . . . 1 . . . 1     . . . . . . . .     . . . . . . . .
    1 . . 1 . . 1 .     1 1 1 1 1 1 1 1     1 . . 1 . . 1 .
    . 1 . 1 . 1 . .     . . . . . . . .     . . . . . . . .
    . . 1 1 1 . . .     . . . . . . . .     . . . . . . . .
    1 1 1 * 1 1 1 1  &  . . . * . . . .  =  . . . * . . . .
    . . 1 1 1 . . .     . . . . . . . .     . . . . . . . .
    . 1 . 1 . 1 . .     . . . . . . . .     . . . . . . . .
    1 . . 1 . . 1 .     . . . . . . . .     . . . . . . . .
    --}

    it "include intersection" $ do
      let allMoves       = Bitboard 9820426766351346249
      let enemyPieces    = Bitboard 71776119061217280
      let attackedPieces = Bitboard 20547673299877888
      (allMoves `bitboardIntersect` enemyPieces) `shouldBe` attackedPieces

    {--
    . . . 1 . . . .     . . . . . . . 1     . . . 1 . . . 1
    . . . 1 . . . .     1 . . . . . 1 .     1 . . 1 . . 1 .
    . . . 1 . . . .     . 1 . . . 1 . .     . 1 . 1 . 1 . .
    . . . 1 . . . .     . . 1 . 1 . . .     . . 1 1 1 . . .
    1 1 1 * 1 1 1 1  |  . . . * . . . .  =  1 1 1 * 1 1 1 1
    . . . 1 . . . .     . . 1 . 1 . . .     . . 1 1 1 . . .
    . . . 1 . . . .     . 1 . . . 1 . .     . 1 . 1 . 1 . .
    . . . 1 . . . .     1 . . . . . 1 .     1 . . 1 . . 1 .

    0000100000001000000010000000100011110111000010000000100000001000
    --}

    it "include union" $ do
      let rookMoves   = Bitboard 578721386714368008
      let bishopMoves = Bitboard 9241705379636978241
      let queenMoves  = Bitboard 9820426766351346249
      (rookMoves `bitboardUnion` bishopMoves) `shouldBe` queenMoves

  describe "line attacks" $ do
    it "can calculate line attacks for any given rank" $ do
      let squareOnRankIsPresent r = isOccupied (rankMask r)
      let squaresOnRank r = map (8 * r +) [0..7]
      let allSquaresOnRankArePresent = liftA2 all squareOnRankIsPresent squaresOnRank

      forAll ranks allSquaresOnRankArePresent

    it "can calculate line attacks for any given file" $ do
      let squareOnFileIsPresent f = isOccupied (fileMask f)
      let squaresOnFile f = map (\offset -> f + 8 * offset) [0..7]
      let allSquaresOnFileArePresent = liftA2 all squareOnFileIsPresent squaresOnFile

      forAll files allSquaresOnFileArePresent

    it "can calculate line attacks for any given diagonal" $ do
      let squareOnDiagonalIsPresent d = isOccupied (diagonalMask d)
      let squaresOnDiagonal d = map (\offset -> if d >= 0 then 8 * d + 9 * offset else (-1) * d + 9 * offset) [0..(7 - abs d)]
      let allSquaresOnDiagonalArePresent = liftA2 all squareOnDiagonalIsPresent squaresOnDiagonal

      forAll diagonals allSquaresOnDiagonalArePresent

    it "can calculate line attacks for any given diagonal" $ do
      let squareOnAntiDiagonalIsPresent d = isOccupied (antiDiagonalMask d)
      let squaresOnAntiDiagonal d = map (\offset -> if d <= 7 then (8 * d) - (7 * offset) else ((56 + (d - 7)) - (7 * offset))) [0.. 7 - (abs (d - 7))]
      let allSquaresOnAntiDiagonalArePresent = liftA2 all squareOnAntiDiagonalIsPresent squaresOnAntiDiagonal

      forAll antiDiagonals allSquaresOnAntiDiagonalArePresent

  describe "ray attacks" $ do
    it "can calculate the north ray attack starting from an origin square" $ do
      let squareOnNorthRayIsPresent origin = isOccupied (northRay origin)
      let squaresOnNorthRay (rank, file) = map (\offset -> (8 * rank + file) + 8 * offset) [1..7-rank]
      let allSquaresOnNorthRayArePresent = liftA2 all squareOnNorthRayIsPresent squaresOnNorthRay

      forAll rankAndFileIndices allSquaresOnNorthRayArePresent

    it "can calculate the south ray attack starting from an origin square" $ do
      let squareOnSouthRayIsPresent origin = isOccupied (southRay origin)
      let squaresOnSouthRay (rank, file) = map (\offset -> (8 * rank + file) - 8 * offset) [1..rank]
      let allSquaresOnSouthRayArePresent = liftA2 all squareOnSouthRayIsPresent squaresOnSouthRay

      forAll rankAndFileIndices allSquaresOnSouthRayArePresent

    it "can calculate the east ray attack starting from an origin square" $ do
      let squareOnEastRayIsPresent origin = isOccupied (eastRay origin)
      let squaresOnEastRay (rank, file) = map (\offset -> (8 * rank + file) + offset) [1..7-file]
      let allSquaresOnEastRayArePresent = liftA2 all squareOnEastRayIsPresent squaresOnEastRay

      forAll rankAndFileIndices allSquaresOnEastRayArePresent

    it "can calculate the west ray attack starting from an origin square" $ do
      let squareOnWestRayIsPresent origin = isOccupied (westRay origin)
      let squaresOnWestRay (rank, file) = map (\offset -> (8 * rank + file) - offset) [1..file]
      let allSquaresOnWestRayArePresent = liftA2 all squareOnWestRayIsPresent squaresOnWestRay

      forAll rankAndFileIndices allSquaresOnWestRayArePresent

  describe "translations" $ do
    it "can translate bitboards in the north direction" $ do
      {--
      . . . 1 . . . 1     1 . . 1 . . 1 .
      1 . . 1 . . 1 .     . 1 . 1 . 1 . .
      . 1 . 1 . 1 . .     . . 1 1 1 . . .
      . . 1 1 1 . . .     1 1 1 * 1 1 1 1
      1 1 1 * 1 1 1 1 =>  . . 1 1 1 . . .
      . . 1 1 1 . . .     . 1 . 1 . 1 . .
      . 1 . 1 . 1 . .     1 . . 1 . . 1 .
      1 . . 1 . . 1 .     . . . 1 . . . 1
      --}

      translateNorth (Bitboard 9820426766351346249) `shouldBe` Bitboard 5272058161445620104

  describe "conversion from regular board representations" $ do

    it "can produce an occupancy bitboard for white pawns" $ do
      whitePawnOccupancyFor (placement startingPos) `shouldBe` Bitboard 65280

    it "can produce an occupancy bitboard for black pawns" $ do
      blackPawnOccupancyFor (placement startingPos) `shouldBe` Bitboard 71776119061217280

    it "can produce an occupancy bitboard for white knights" $ do
      whiteKnightOccupancyFor (placement startingPos) `shouldBe` Bitboard 66

    it "can produce an occupancy bitboard for black knights" $ do
      blackKnightOccupancyFor (placement startingPos) `shouldBe` Bitboard 4755801206503243776

    it "can produce an occupancy bitboard for white bishops" $ do
      whiteBishopOccupancyFor (placement startingPos) `shouldBe` Bitboard 36

    it "can produce an occupancy bitboard for black bishops" $ do
      blackBishopOccupancyFor (placement startingPos) `shouldBe` Bitboard 2594073385365405696

    it "can produce an occupancy bitboard for white rooks" $ do
      whiteRookOccupancyFor (placement startingPos) `shouldBe` Bitboard 129

    it "can produce an occupancy bitboard for black rooks" $ do
      blackRookOccupancyFor (placement startingPos) `shouldBe` Bitboard 9295429630892703744

    it "can produce an occupancy bitboard for white queens" $ do
      whiteQueenOccupancyFor (placement startingPos) `shouldBe` Bitboard 8

    it "can produce an occupancy bitboard for black queens" $ do
      blackQueenOccupancyFor (placement startingPos) `shouldBe` Bitboard 576460752303423488

    it "can produce an occupancy bitboard for white kings" $ do
      whiteKingOccupancyFor (placement startingPos) `shouldBe` Bitboard 16

    it "can produce an occupancy bitboard for black kings" $ do
      blackKingOccupancyFor (placement startingPos) `shouldBe` Bitboard 1152921504606846976

    it "can convert a RegularBoardRepresentation into a BitboardRepresentation" $ do
      regularToBitboard (placement startingPos) `shouldBe` BitboardRepresentation
        { whitePawns   = Bitboard 65280
        , blackPawns   = Bitboard 71776119061217280
        , whiteKnights = Bitboard 66
        , blackKnights = Bitboard 4755801206503243776
        , whiteBishops = Bitboard 36
        , blackBishops = Bitboard 2594073385365405696
        , whiteRooks   = Bitboard 129
        , blackRooks   = Bitboard 9295429630892703744
        , whiteQueens  = Bitboard 8
        , blackQueens  = Bitboard 576460752303423488
        , whiteKings   = Bitboard 16
        , blackKings   = Bitboard 1152921504606846976
        }
