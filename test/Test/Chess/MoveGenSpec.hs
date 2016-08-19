module Test.Chess.MoveGenSpec where

import Chess.Base

import Chess.MoveGen
import Chess.MoveGen.Bishop

import Control.Monad

import Test.Placements
import Test.Placements.Bishop
import Test.Placements.King
import Test.Placements.Knight
import Test.Placements.Pawn
import Test.Placements.Queen
import Test.Placements.Rook

import Test.Hspec
import Test.QuickCheck

coords :: Gen Coordinate
coords = choose ('a', 'h') >>= (\x -> liftM (Coordinate x) (choose (1, 8)))

spec :: Spec
spec =
  context "potential move generation" $ do

    describe "alongRay" $ do
      context "verticals" $ do
        it "returns a list of coordinates along the north vertical ray, including the destination" $
          alongRay (Coordinate 'a' 1, Coordinate 'a' 8) `shouldBe`
            [ Coordinate 'a' 2
            , Coordinate 'a' 3
            , Coordinate 'a' 4
            , Coordinate 'a' 5
            , Coordinate 'a' 6
            , Coordinate 'a' 7
            , Coordinate 'a' 8
            ]

        it "returns a list of coordinates along the south vertical ray, including the destination" $
          alongRay (Coordinate 'a' 8, Coordinate 'a' 1) `shouldBe`
            [ Coordinate 'a' 7
            , Coordinate 'a' 6
            , Coordinate 'a' 5
            , Coordinate 'a' 4
            , Coordinate 'a' 3
            , Coordinate 'a' 2
            , Coordinate 'a' 1
            ]

      context "horizontals" $ do
        it "returns a list of coordinates along the east horizontal ray, including the destination" $
          alongRay (Coordinate 'a' 1, Coordinate 'h' 1) `shouldBe`
            [ Coordinate 'b' 1
            , Coordinate 'c' 1
            , Coordinate 'd' 1
            , Coordinate 'e' 1
            , Coordinate 'f' 1
            , Coordinate 'g' 1
            , Coordinate 'h' 1
            ]

        it "returns a list of coordinates along the west horizontal ray, including the destination" $
          alongRay (Coordinate 'h' 1, Coordinate 'a' 1) `shouldBe`
            [ Coordinate 'g' 1
            , Coordinate 'f' 1
            , Coordinate 'e' 1
            , Coordinate 'd' 1
            , Coordinate 'c' 1
            , Coordinate 'b' 1
            , Coordinate 'a' 1
            ]

    describe "isBlocked" $ do

      context "verticals" $ do
        it "returns True if the destination point is behind another friendly piece along the ray" $
          isBlocked (placement rookTest) Move { moveFrom = Coordinate 'd' 5, moveTo = Coordinate 'd' 1, moveType = Standard, movePromoteTo = Nothing } `shouldBe` True

        it "returns True if the destination point is behind another enemy piece along the ray" $
          isBlocked (placement rookCaptureVerticalTest) Move { moveFrom = Coordinate 'd' 5, moveTo = Coordinate 'd' 8, moveType = Standard, movePromoteTo = Nothing } `shouldBe` True

        it "returns False if the destination point is in front of another piece along the ray" $
          isBlocked (placement rookTest) Move { moveFrom = Coordinate 'd' 5, moveTo = Coordinate 'd' 4, moveType = Standard, movePromoteTo = Nothing } `shouldBe` False

        it "returns False if the ray is not blocked, moving north" $
          isBlocked (placement rookTest) Move { moveFrom = Coordinate 'd' 5, moveTo = Coordinate 'd' 8, moveType = Standard, movePromoteTo = Nothing } `shouldBe` False

        it "returns False if the ray is not blocked, moving south" $
          isBlocked (placement onlyRookTest) Move { moveFrom = Coordinate 'd' 5, moveTo = Coordinate 'd' 3, moveType = Standard, movePromoteTo = Nothing } `shouldBe` False

        it "returns False if the destination square is occupied by an enemy piece" $
          isBlocked (placement rookCaptureVerticalTest) Move { moveFrom = Coordinate 'd' 5, moveTo = Coordinate 'd' 7, moveType = Standard, movePromoteTo = Nothing } `shouldBe` False

      context "horizontals" $ do
        it "returns True if the destination point is behind another piece along the ray" $
          isBlocked (placement rookTest) Move { moveFrom = Coordinate 'd' 5, moveTo = Coordinate 'h' 5, moveType = Standard, movePromoteTo = Nothing } `shouldBe` True

        it "returns True if the destination point is behind another enemy piece along the ray" $
          isBlocked (placement rookCaptureHorizontalTest) Move { moveFrom = Coordinate 'd' 5, moveTo = Coordinate 'g' 5, moveType = Standard, movePromoteTo = Nothing } `shouldBe` True

        it "returns False if the destination point is in front of another piece along the ray" $
          isBlocked (placement rookTest) Move { moveFrom = Coordinate 'd' 5, moveTo = Coordinate 'e' 5, moveType = Standard, movePromoteTo = Nothing } `shouldBe` False

        it "returns False if the ray is not blocked, moving west" $
          isBlocked (placement rookTest) Move { moveFrom = Coordinate 'd' 5, moveTo = Coordinate 'a' 5, moveType = Standard, movePromoteTo = Nothing } `shouldBe` False

        it "returns False if the ray is not blocked, moving east" $
          isBlocked (placement onlyRookTest) Move { moveFrom = Coordinate 'd' 5, moveTo = Coordinate 'h' 5, moveType = Standard, movePromoteTo = Nothing } `shouldBe` False

        it "returns False if the destination square is occupied by an enemy piece" $
          isBlocked (placement rookCaptureHorizontalTest) Move { moveFrom = Coordinate 'd' 5, moveTo = Coordinate 'f' 5, moveType = Standard, movePromoteTo = Nothing } `shouldBe` False

      context "diagonals" $ do
        it "returns True if the destination point is behind another piece along the ray" $
          isBlocked (placement diagonalTest) Move { moveFrom = Coordinate 'd' 5, moveTo = Coordinate 'g' 8, moveType = Standard, movePromoteTo = Nothing } `shouldBe` True

        it "returns True if the destination point is behind another piece along the ray" $
          isBlocked (placement bishopCaptureTest) Move { moveFrom = Coordinate 'a' 1, moveTo = Coordinate 'h' 8, moveType = Standard, movePromoteTo = Nothing } `shouldBe` True

        it "returns False if the destination point is in front of another piece along the ray" $
          isBlocked (placement diagonalTest) Move { moveFrom = Coordinate 'd' 5, moveTo = Coordinate 'e' 6, moveType = Standard, movePromoteTo = Nothing } `shouldBe` False

        it "returns False if the ray is not blocked" $
          isBlocked (placement diagonalTest) Move { moveFrom = Coordinate 'd' 5, moveTo = Coordinate 'a' 8, moveType = Standard, movePromoteTo = Nothing } `shouldBe` False

        it "returns False if the destination square is occupied by an enemy piece" $
          isBlocked (placement bishopCaptureTest) Move { moveFrom = Coordinate 'a' 1, moveTo = Coordinate 'd' 4, moveType = Standard, movePromoteTo = Nothing } `shouldBe` False

    describe "potentialRookMoves" $ do

      it "never produces moves off the board" $
        property $ forAll coords $ \c -> all (isOnBoard . moveTo) $ potentialRookMoves (placePiece emptyTest (Piece Rook White) c) c

      it "produces the correct set of moves without being blocked by pieces" $
        potentialRookMoves onlyRookTest (Coordinate 'd' 5) `shouldBe`
          [ Move { moveFrom = Coordinate 'd' 5, moveTo = Coordinate 'e' 5, moveType = Standard, movePromoteTo = Nothing }
          , Move { moveFrom = Coordinate 'd' 5, moveTo = Coordinate 'c' 5, moveType = Standard, movePromoteTo = Nothing }
          , Move { moveFrom = Coordinate 'd' 5, moveTo = Coordinate 'd' 6, moveType = Standard, movePromoteTo = Nothing }
          , Move { moveFrom = Coordinate 'd' 5, moveTo = Coordinate 'd' 4, moveType = Standard, movePromoteTo = Nothing }
          , Move { moveFrom = Coordinate 'd' 5, moveTo = Coordinate 'f' 5, moveType = Standard, movePromoteTo = Nothing }
          , Move { moveFrom = Coordinate 'd' 5, moveTo = Coordinate 'b' 5, moveType = Standard, movePromoteTo = Nothing }
          , Move { moveFrom = Coordinate 'd' 5, moveTo = Coordinate 'd' 7, moveType = Standard, movePromoteTo = Nothing }
          , Move { moveFrom = Coordinate 'd' 5, moveTo = Coordinate 'd' 3, moveType = Standard, movePromoteTo = Nothing }
          , Move { moveFrom = Coordinate 'd' 5, moveTo = Coordinate 'g' 5, moveType = Standard, movePromoteTo = Nothing }
          , Move { moveFrom = Coordinate 'd' 5, moveTo = Coordinate 'a' 5, moveType = Standard, movePromoteTo = Nothing }
          , Move { moveFrom = Coordinate 'd' 5, moveTo = Coordinate 'd' 8, moveType = Standard, movePromoteTo = Nothing }
          , Move { moveFrom = Coordinate 'd' 5, moveTo = Coordinate 'd' 2, moveType = Standard, movePromoteTo = Nothing }
          , Move { moveFrom = Coordinate 'd' 5, moveTo = Coordinate 'h' 5, moveType = Standard, movePromoteTo = Nothing }
          , Move { moveFrom = Coordinate 'd' 5, moveTo = Coordinate 'd' 1, moveType = Standard, movePromoteTo = Nothing }
          ]

      it "produces the correct set of moves when blocked by some pieces" $
        potentialRookMoves rookTest (Coordinate 'd' 5) `shouldBe`
          [ Move { moveFrom = Coordinate 'd' 5, moveTo = Coordinate 'e' 5, moveType = Standard, movePromoteTo = Nothing }
          , Move { moveFrom = Coordinate 'd' 5, moveTo = Coordinate 'c' 5, moveType = Standard, movePromoteTo = Nothing }
          , Move { moveFrom = Coordinate 'd' 5, moveTo = Coordinate 'd' 6, moveType = Standard, movePromoteTo = Nothing }
          , Move { moveFrom = Coordinate 'd' 5, moveTo = Coordinate 'd' 4, moveType = Standard, movePromoteTo = Nothing }
          , Move { moveFrom = Coordinate 'd' 5, moveTo = Coordinate 'b' 5, moveType = Standard, movePromoteTo = Nothing }
          , Move { moveFrom = Coordinate 'd' 5, moveTo = Coordinate 'd' 7, moveType = Standard, movePromoteTo = Nothing }
          , Move { moveFrom = Coordinate 'd' 5, moveTo = Coordinate 'a' 5, moveType = Standard, movePromoteTo = Nothing }
          , Move { moveFrom = Coordinate 'd' 5, moveTo = Coordinate 'd' 8, moveType = Standard, movePromoteTo = Nothing }
          ]

      it "produces the correct set of moves, including captures" $
        potentialRookMoves rookAllCapturesTest (Coordinate 'd' 5) `shouldBe`
          [ Move { moveFrom = Coordinate 'd' 5, moveTo = Coordinate 'e' 5, moveType = Standard, movePromoteTo = Nothing }
          , Move { moveFrom = Coordinate 'd' 5, moveTo = Coordinate 'c' 5, moveType = Standard, movePromoteTo = Nothing }
          , Move { moveFrom = Coordinate 'd' 5, moveTo = Coordinate 'd' 6, moveType = Standard, movePromoteTo = Nothing }
          , Move { moveFrom = Coordinate 'd' 5, moveTo = Coordinate 'd' 4, moveType = Standard, movePromoteTo = Nothing }
          , Move { moveFrom = Coordinate 'd' 5, moveTo = Coordinate 'f' 5, moveType = Capture, movePromoteTo = Nothing }
          , Move { moveFrom = Coordinate 'd' 5, moveTo = Coordinate 'b' 5, moveType = Capture, movePromoteTo = Nothing }
          , Move { moveFrom = Coordinate 'd' 5, moveTo = Coordinate 'd' 7, moveType = Capture, movePromoteTo = Nothing }
          , Move { moveFrom = Coordinate 'd' 5, moveTo = Coordinate 'd' 3, moveType = Capture, movePromoteTo = Nothing }
          ]

      it "does not allow a rook to capture pieces of its own color" $
        potentialRookMoves (setupGame [ (Piece King White, Coordinate 'e' 1)
                                      , (Piece Rook White, Coordinate 'h' 1)
                                      ]) (Coordinate 'h' 1) `shouldBe`
          [ Move { moveFrom = Coordinate 'h' 1, moveTo = Coordinate 'g' 1, moveType = Standard, movePromoteTo = Nothing }
          , Move { moveFrom = Coordinate 'h' 1, moveTo = Coordinate 'h' 2, moveType = Standard, movePromoteTo = Nothing }
          , Move { moveFrom = Coordinate 'h' 1, moveTo = Coordinate 'f' 1, moveType = Standard, movePromoteTo = Nothing }
          , Move { moveFrom = Coordinate 'h' 1, moveTo = Coordinate 'h' 3, moveType = Standard, movePromoteTo = Nothing }
          , Move { moveFrom = Coordinate 'h' 1, moveTo = Coordinate 'h' 4, moveType = Standard, movePromoteTo = Nothing }
          , Move { moveFrom = Coordinate 'h' 1, moveTo = Coordinate 'h' 5, moveType = Standard, movePromoteTo = Nothing }
          , Move { moveFrom = Coordinate 'h' 1, moveTo = Coordinate 'h' 6, moveType = Standard, movePromoteTo = Nothing }
          , Move { moveFrom = Coordinate 'h' 1, moveTo = Coordinate 'h' 7, moveType = Standard, movePromoteTo = Nothing }
          , Move { moveFrom = Coordinate 'h' 1, moveTo = Coordinate 'h' 8, moveType = Standard, movePromoteTo = Nothing }
          ]



    describe "potentialKnightMoves" $ do

      it "never produces moves off the board" $
        property $ forAll coords $ \c -> all (isOnBoard . moveTo) $ potentialKnightMoves (placePiece emptyTest (Piece Knight White) c) c

      it "produces the correct set of moves without being blocked by pieces" $
        potentialKnightMoves onlyKnightTest (Coordinate 'd' 4) `shouldBe`
          [ Move { moveFrom = Coordinate 'd' 4, moveTo = Coordinate 'b' 3, moveType = Standard, movePromoteTo = Nothing }
          , Move { moveFrom = Coordinate 'd' 4, moveTo = Coordinate 'b' 5, moveType = Standard, movePromoteTo = Nothing }
          , Move { moveFrom = Coordinate 'd' 4, moveTo = Coordinate 'c' 2, moveType = Standard, movePromoteTo = Nothing }
          , Move { moveFrom = Coordinate 'd' 4, moveTo = Coordinate 'c' 6, moveType = Standard, movePromoteTo = Nothing }
          , Move { moveFrom = Coordinate 'd' 4, moveTo = Coordinate 'e' 2, moveType = Standard, movePromoteTo = Nothing }
          , Move { moveFrom = Coordinate 'd' 4, moveTo = Coordinate 'e' 6, moveType = Standard, movePromoteTo = Nothing }
          , Move { moveFrom = Coordinate 'd' 4, moveTo = Coordinate 'f' 3, moveType = Standard, movePromoteTo = Nothing }
          , Move { moveFrom = Coordinate 'd' 4, moveTo = Coordinate 'f' 5, moveType = Standard, movePromoteTo = Nothing }
          ]

      it "produces the correct set of moves when blocked by some pieces" $
        potentialKnightMoves knightTest (Coordinate 'd' 4) `shouldBe`
          [ Move { moveFrom = Coordinate 'd' 4, moveTo = Coordinate 'b' 3, moveType = Standard, movePromoteTo = Nothing }
          , Move { moveFrom = Coordinate 'd' 4, moveTo = Coordinate 'c' 2, moveType = Standard, movePromoteTo = Nothing }
          , Move { moveFrom = Coordinate 'd' 4, moveTo = Coordinate 'c' 6, moveType = Standard, movePromoteTo = Nothing }
          , Move { moveFrom = Coordinate 'd' 4, moveTo = Coordinate 'e' 2, moveType = Standard, movePromoteTo = Nothing }
          , Move { moveFrom = Coordinate 'd' 4, moveTo = Coordinate 'e' 6, moveType = Standard, movePromoteTo = Nothing }
          , Move { moveFrom = Coordinate 'd' 4, moveTo = Coordinate 'f' 5, moveType = Standard, movePromoteTo = Nothing }
          ]

      it "can jump over pieces" $
        potentialKnightMoves startingPos (Coordinate 'b' 1) `shouldBe`
          [ Move { moveFrom = Coordinate 'b' 1, moveTo = Coordinate 'a' 3, moveType = Standard, movePromoteTo = Nothing }
          , Move { moveFrom = Coordinate 'b' 1, moveTo = Coordinate 'c' 3, moveType = Standard, movePromoteTo = Nothing }
          ]

    describe "potentialQueenMoves" $

      context "movement" $ do

        it "never produces moves off the board" $
          property $ forAll coords $ \c -> all (isOnBoard . moveTo) $ potentialQueenMoves (placePiece emptyTest (Piece Queen White) c) c

        it "produces the correct set of moves without being blocked by pieces" $
          potentialQueenMoves onlyQueenTest (Coordinate 'd' 4) `shouldBe`
            [ Move { moveFrom = Coordinate 'd' 4, moveTo = Coordinate 'e' 4, moveType = Standard, movePromoteTo = Nothing }
            , Move { moveFrom = Coordinate 'd' 4, moveTo = Coordinate 'c' 4, moveType = Standard, movePromoteTo = Nothing }
            , Move { moveFrom = Coordinate 'd' 4, moveTo = Coordinate 'd' 5, moveType = Standard, movePromoteTo = Nothing }
            , Move { moveFrom = Coordinate 'd' 4, moveTo = Coordinate 'd' 3, moveType = Standard, movePromoteTo = Nothing }
            , Move { moveFrom = Coordinate 'd' 4, moveTo = Coordinate 'f' 4, moveType = Standard, movePromoteTo = Nothing }
            , Move { moveFrom = Coordinate 'd' 4, moveTo = Coordinate 'b' 4, moveType = Standard, movePromoteTo = Nothing }
            , Move { moveFrom = Coordinate 'd' 4, moveTo = Coordinate 'd' 6, moveType = Standard, movePromoteTo = Nothing }
            , Move { moveFrom = Coordinate 'd' 4, moveTo = Coordinate 'd' 2, moveType = Standard, movePromoteTo = Nothing }
            , Move { moveFrom = Coordinate 'd' 4, moveTo = Coordinate 'g' 4, moveType = Standard, movePromoteTo = Nothing }
            , Move { moveFrom = Coordinate 'd' 4, moveTo = Coordinate 'a' 4, moveType = Standard, movePromoteTo = Nothing }
            , Move { moveFrom = Coordinate 'd' 4, moveTo = Coordinate 'd' 7, moveType = Standard, movePromoteTo = Nothing }
            , Move { moveFrom = Coordinate 'd' 4, moveTo = Coordinate 'd' 1, moveType = Standard, movePromoteTo = Nothing }
            , Move { moveFrom = Coordinate 'd' 4, moveTo = Coordinate 'h' 4, moveType = Standard, movePromoteTo = Nothing }
            , Move { moveFrom = Coordinate 'd' 4, moveTo = Coordinate 'd' 8, moveType = Standard, movePromoteTo = Nothing }
            , Move { moveFrom = Coordinate 'd' 4, moveTo = Coordinate 'c' 5, moveType = Standard, movePromoteTo = Nothing }
            , Move { moveFrom = Coordinate 'd' 4, moveTo = Coordinate 'e' 5, moveType = Standard, movePromoteTo = Nothing }
            , Move { moveFrom = Coordinate 'd' 4, moveTo = Coordinate 'e' 3, moveType = Standard, movePromoteTo = Nothing }
            , Move { moveFrom = Coordinate 'd' 4, moveTo = Coordinate 'c' 3, moveType = Standard, movePromoteTo = Nothing }
            , Move { moveFrom = Coordinate 'd' 4, moveTo = Coordinate 'b' 6, moveType = Standard, movePromoteTo = Nothing }
            , Move { moveFrom = Coordinate 'd' 4, moveTo = Coordinate 'f' 6, moveType = Standard, movePromoteTo = Nothing }
            , Move { moveFrom = Coordinate 'd' 4, moveTo = Coordinate 'f' 2, moveType = Standard, movePromoteTo = Nothing }
            , Move { moveFrom = Coordinate 'd' 4, moveTo = Coordinate 'b' 2, moveType = Standard, movePromoteTo = Nothing }
            , Move { moveFrom = Coordinate 'd' 4, moveTo = Coordinate 'a' 7, moveType = Standard, movePromoteTo = Nothing }
            , Move { moveFrom = Coordinate 'd' 4, moveTo = Coordinate 'g' 7, moveType = Standard, movePromoteTo = Nothing }
            , Move { moveFrom = Coordinate 'd' 4, moveTo = Coordinate 'g' 1, moveType = Standard, movePromoteTo = Nothing }
            , Move { moveFrom = Coordinate 'd' 4, moveTo = Coordinate 'a' 1, moveType = Standard, movePromoteTo = Nothing }
            , Move { moveFrom = Coordinate 'd' 4, moveTo = Coordinate 'h' 8, moveType = Standard, movePromoteTo = Nothing }
            ]

        it "produces the correct set of moves when blocked by some pieces" $
          potentialQueenMoves queenTest (Coordinate 'd' 4) `shouldBe`
            [ Move { moveFrom = Coordinate 'd' 4, moveTo = Coordinate 'e' 4, moveType = Standard, movePromoteTo = Nothing }
            , Move { moveFrom = Coordinate 'd' 4, moveTo = Coordinate 'c' 4, moveType = Standard, movePromoteTo = Nothing }
            , Move { moveFrom = Coordinate 'd' 4, moveTo = Coordinate 'd' 5, moveType = Standard, movePromoteTo = Nothing }
            , Move { moveFrom = Coordinate 'd' 4, moveTo = Coordinate 'd' 3, moveType = Standard, movePromoteTo = Nothing }
            , Move { moveFrom = Coordinate 'd' 4, moveTo = Coordinate 'f' 4, moveType = Standard, movePromoteTo = Nothing }
            , Move { moveFrom = Coordinate 'd' 4, moveTo = Coordinate 'b' 4, moveType = Standard, movePromoteTo = Nothing }
            , Move { moveFrom = Coordinate 'd' 4, moveTo = Coordinate 'd' 6, moveType = Standard, movePromoteTo = Nothing }
            , Move { moveFrom = Coordinate 'd' 4, moveTo = Coordinate 'd' 2, moveType = Standard, movePromoteTo = Nothing }
            , Move { moveFrom = Coordinate 'd' 4, moveTo = Coordinate 'g' 4, moveType = Standard, movePromoteTo = Nothing }
            , Move { moveFrom = Coordinate 'd' 4, moveTo = Coordinate 'a' 4, moveType = Standard, movePromoteTo = Nothing }
            , Move { moveFrom = Coordinate 'd' 4, moveTo = Coordinate 'd' 1, moveType = Standard, movePromoteTo = Nothing }
            , Move { moveFrom = Coordinate 'd' 4, moveTo = Coordinate 'h' 4, moveType = Standard, movePromoteTo = Nothing }
            , Move { moveFrom = Coordinate 'd' 4, moveTo = Coordinate 'c' 5, moveType = Standard, movePromoteTo = Nothing }
            , Move { moveFrom = Coordinate 'd' 4, moveTo = Coordinate 'e' 5, moveType = Standard, movePromoteTo = Nothing }
            , Move { moveFrom = Coordinate 'd' 4, moveTo = Coordinate 'e' 3, moveType = Standard, movePromoteTo = Nothing }
            , Move { moveFrom = Coordinate 'd' 4, moveTo = Coordinate 'c' 3, moveType = Standard, movePromoteTo = Nothing }
            , Move { moveFrom = Coordinate 'd' 4, moveTo = Coordinate 'b' 6, moveType = Standard, movePromoteTo = Nothing }
            , Move { moveFrom = Coordinate 'd' 4, moveTo = Coordinate 'f' 6, moveType = Standard, movePromoteTo = Nothing }
            , Move { moveFrom = Coordinate 'd' 4, moveTo = Coordinate 'f' 2, moveType = Standard, movePromoteTo = Nothing }
            , Move { moveFrom = Coordinate 'd' 4, moveTo = Coordinate 'b' 2, moveType = Standard, movePromoteTo = Nothing }
            , Move { moveFrom = Coordinate 'd' 4, moveTo = Coordinate 'a' 7, moveType = Standard, movePromoteTo = Nothing }
            , Move { moveFrom = Coordinate 'd' 4, moveTo = Coordinate 'g' 1, moveType = Standard, movePromoteTo = Nothing }
            , Move { moveFrom = Coordinate 'd' 4, moveTo = Coordinate 'a' 1, moveType = Standard, movePromoteTo = Nothing }
            ]

        it "produces the correct set of moves, including captures" $
          potentialQueenMoves queenCaptureTest (Coordinate 'd' 4) `shouldBe`
            [ Move { moveFrom = Coordinate 'd' 4, moveTo = Coordinate 'e' 4, moveType = Standard, movePromoteTo = Nothing }
            , Move { moveFrom = Coordinate 'd' 4, moveTo = Coordinate 'c' 4, moveType = Standard, movePromoteTo = Nothing }
            , Move { moveFrom = Coordinate 'd' 4, moveTo = Coordinate 'd' 5, moveType = Standard, movePromoteTo = Nothing }
            , Move { moveFrom = Coordinate 'd' 4, moveTo = Coordinate 'd' 3, moveType = Standard, movePromoteTo = Nothing }
            , Move { moveFrom = Coordinate 'd' 4, moveTo = Coordinate 'f' 4, moveType = Standard, movePromoteTo = Nothing }
            , Move { moveFrom = Coordinate 'd' 4, moveTo = Coordinate 'b' 4, moveType = Standard, movePromoteTo = Nothing }
            , Move { moveFrom = Coordinate 'd' 4, moveTo = Coordinate 'd' 6, moveType = Standard, movePromoteTo = Nothing }
            , Move { moveFrom = Coordinate 'd' 4, moveTo = Coordinate 'd' 2, moveType = Standard, movePromoteTo = Nothing }
            , Move { moveFrom = Coordinate 'd' 4, moveTo = Coordinate 'g' 4, moveType = Standard, movePromoteTo = Nothing }
            , Move { moveFrom = Coordinate 'd' 4, moveTo = Coordinate 'a' 4, moveType = Standard, movePromoteTo = Nothing }
            , Move { moveFrom = Coordinate 'd' 4, moveTo = Coordinate 'd' 7, moveType = Capture, movePromoteTo = Nothing }
            , Move { moveFrom = Coordinate 'd' 4, moveTo = Coordinate 'd' 1, moveType = Standard, movePromoteTo = Nothing }
            , Move { moveFrom = Coordinate 'd' 4, moveTo = Coordinate 'h' 4, moveType = Standard, movePromoteTo = Nothing }
            , Move { moveFrom = Coordinate 'd' 4, moveTo = Coordinate 'c' 5, moveType = Standard, movePromoteTo = Nothing }
            , Move { moveFrom = Coordinate 'd' 4, moveTo = Coordinate 'e' 5, moveType = Standard, movePromoteTo = Nothing }
            , Move { moveFrom = Coordinate 'd' 4, moveTo = Coordinate 'e' 3, moveType = Standard, movePromoteTo = Nothing }
            , Move { moveFrom = Coordinate 'd' 4, moveTo = Coordinate 'c' 3, moveType = Standard, movePromoteTo = Nothing }
            , Move { moveFrom = Coordinate 'd' 4, moveTo = Coordinate 'b' 6, moveType = Standard, movePromoteTo = Nothing }
            , Move { moveFrom = Coordinate 'd' 4, moveTo = Coordinate 'f' 6, moveType = Standard, movePromoteTo = Nothing }
            , Move { moveFrom = Coordinate 'd' 4, moveTo = Coordinate 'f' 2, moveType = Standard, movePromoteTo = Nothing }
            , Move { moveFrom = Coordinate 'd' 4, moveTo = Coordinate 'b' 2, moveType = Standard, movePromoteTo = Nothing }
            , Move { moveFrom = Coordinate 'd' 4, moveTo = Coordinate 'a' 7, moveType = Standard, movePromoteTo = Nothing }
            , Move { moveFrom = Coordinate 'd' 4, moveTo = Coordinate 'g' 7, moveType = Capture, movePromoteTo = Nothing }
            , Move { moveFrom = Coordinate 'd' 4, moveTo = Coordinate 'g' 1, moveType = Standard, movePromoteTo = Nothing }
            , Move { moveFrom = Coordinate 'd' 4, moveTo = Coordinate 'a' 1, moveType = Standard, movePromoteTo = Nothing }
            ]


    describe "potentialKingMoves" $

      context "movement" $ do

        it "never produces moves off the board" $
          property $ forAll coords $ \c -> all (isOnBoard . moveTo) $ potentialKingMoves (placePiece emptyTest (Piece King White) c) c

        it "allows the king to move to any square in its Moore neighbourhood" $
          potentialKingMoves onlyKingTest { castlingRights = CastleRights False False False False } (Coordinate 'd' 4) `shouldBe`
            [ Move { moveFrom = Coordinate 'd' 4, moveTo = Coordinate 'c' 4, moveType = Standard, movePromoteTo = Nothing }
            , Move { moveFrom = Coordinate 'd' 4, moveTo = Coordinate 'c' 5, moveType = Standard, movePromoteTo = Nothing }
            , Move { moveFrom = Coordinate 'd' 4, moveTo = Coordinate 'd' 5, moveType = Standard, movePromoteTo = Nothing }
            , Move { moveFrom = Coordinate 'd' 4, moveTo = Coordinate 'e' 5, moveType = Standard, movePromoteTo = Nothing }
            , Move { moveFrom = Coordinate 'd' 4, moveTo = Coordinate 'e' 4, moveType = Standard, movePromoteTo = Nothing }
            , Move { moveFrom = Coordinate 'd' 4, moveTo = Coordinate 'e' 3, moveType = Standard, movePromoteTo = Nothing }
            , Move { moveFrom = Coordinate 'd' 4, moveTo = Coordinate 'd' 3, moveType = Standard, movePromoteTo = Nothing }
            , Move { moveFrom = Coordinate 'd' 4, moveTo = Coordinate 'c' 3, moveType = Standard, movePromoteTo = Nothing }
            ]

        it "allows the white king to castle kingside, if he has the right to" $
          potentialKingMoves whiteKingOOTest { castlingRights = CastleRights True False False False } (Coordinate 'e' 1) `shouldBe`
            [ Move { moveFrom = Coordinate 'e' 1, moveTo = Coordinate 'd' 1, moveType = Standard, movePromoteTo = Nothing }
            , Move { moveFrom = Coordinate 'e' 1, moveTo = Coordinate 'd' 2, moveType = Standard, movePromoteTo = Nothing }
            , Move { moveFrom = Coordinate 'e' 1, moveTo = Coordinate 'e' 2, moveType = Standard, movePromoteTo = Nothing }
            , Move { moveFrom = Coordinate 'e' 1, moveTo = Coordinate 'f' 2, moveType = Standard, movePromoteTo = Nothing }
            , Move { moveFrom = Coordinate 'e' 1, moveTo = Coordinate 'f' 1, moveType = Standard, movePromoteTo = Nothing }
            , Move { moveFrom = Coordinate 'e' 1, moveTo = Coordinate 'g' 1, moveType = Castle, movePromoteTo = Nothing }
            ]

        it "does not allow the white king to castle kingside, if he does not have the right to" $
          potentialKingMoves whiteKingOOTest { castlingRights = CastleRights False False False False } (Coordinate 'e' 1) `shouldBe`
            [ Move { moveFrom = Coordinate 'e' 1, moveTo = Coordinate 'd' 1, moveType = Standard, movePromoteTo = Nothing }
            , Move { moveFrom = Coordinate 'e' 1, moveTo = Coordinate 'd' 2, moveType = Standard, movePromoteTo = Nothing }
            , Move { moveFrom = Coordinate 'e' 1, moveTo = Coordinate 'e' 2, moveType = Standard, movePromoteTo = Nothing }
            , Move { moveFrom = Coordinate 'e' 1, moveTo = Coordinate 'f' 2, moveType = Standard, movePromoteTo = Nothing }
            , Move { moveFrom = Coordinate 'e' 1, moveTo = Coordinate 'f' 1, moveType = Standard, movePromoteTo = Nothing }
            ]

        it "allows the white king to castle queenside, if he has the right to" $
          potentialKingMoves whiteKingOOOTest { castlingRights = CastleRights False False True False } (Coordinate 'e' 1) `shouldBe`
            [ Move { moveFrom = Coordinate 'e' 1, moveTo = Coordinate 'd' 1, moveType = Standard, movePromoteTo = Nothing }
            , Move { moveFrom = Coordinate 'e' 1, moveTo = Coordinate 'd' 2, moveType = Standard, movePromoteTo = Nothing }
            , Move { moveFrom = Coordinate 'e' 1, moveTo = Coordinate 'e' 2, moveType = Standard, movePromoteTo = Nothing }
            , Move { moveFrom = Coordinate 'e' 1, moveTo = Coordinate 'f' 2, moveType = Standard, movePromoteTo = Nothing }
            , Move { moveFrom = Coordinate 'e' 1, moveTo = Coordinate 'f' 1, moveType = Standard, movePromoteTo = Nothing }
            , Move { moveFrom = Coordinate 'e' 1, moveTo = Coordinate 'c' 1, moveType = Castle, movePromoteTo = Nothing }
            ]

        it "does not allow the white king to castle queenside, if he does not have the right to" $
          potentialKingMoves whiteKingOOOTest { castlingRights = CastleRights False False False False } (Coordinate 'e' 1) `shouldBe`
            [ Move { moveFrom = Coordinate 'e' 1, moveTo = Coordinate 'd' 1, moveType = Standard, movePromoteTo = Nothing }
            , Move { moveFrom = Coordinate 'e' 1, moveTo = Coordinate 'd' 2, moveType = Standard, movePromoteTo = Nothing }
            , Move { moveFrom = Coordinate 'e' 1, moveTo = Coordinate 'e' 2, moveType = Standard, movePromoteTo = Nothing }
            , Move { moveFrom = Coordinate 'e' 1, moveTo = Coordinate 'f' 2, moveType = Standard, movePromoteTo = Nothing }
            , Move { moveFrom = Coordinate 'e' 1, moveTo = Coordinate 'f' 1, moveType = Standard, movePromoteTo = Nothing }
            ]

        it "allows the white king to castle both kingside or queenside, if he has the option" $
          potentialKingMoves whiteKingBothCastlesTest { castlingRights = CastleRights True False True False } (Coordinate 'e' 1) `shouldBe`
            [ Move { moveFrom = Coordinate 'e' 1, moveTo = Coordinate 'd' 1, moveType = Standard, movePromoteTo = Nothing }
            , Move { moveFrom = Coordinate 'e' 1, moveTo = Coordinate 'd' 2, moveType = Standard, movePromoteTo = Nothing }
            , Move { moveFrom = Coordinate 'e' 1, moveTo = Coordinate 'e' 2, moveType = Standard, movePromoteTo = Nothing }
            , Move { moveFrom = Coordinate 'e' 1, moveTo = Coordinate 'f' 2, moveType = Standard, movePromoteTo = Nothing }
            , Move { moveFrom = Coordinate 'e' 1, moveTo = Coordinate 'f' 1, moveType = Standard, movePromoteTo = Nothing }
            , Move { moveFrom = Coordinate 'e' 1, moveTo = Coordinate 'g' 1, moveType = Castle, movePromoteTo = Nothing }
            , Move { moveFrom = Coordinate 'e' 1, moveTo = Coordinate 'c' 1, moveType = Castle, movePromoteTo = Nothing }
            ]

        it "does not allow the white king to castle when he is not on his home square" $
          potentialKingMoves whiteKingMovedNoOOTest { castlingRights = CastleRights True True True True } (Coordinate 'd' 4) `shouldBe`
            [ Move { moveFrom = Coordinate 'd' 4, moveTo = Coordinate 'c' 4, moveType = Standard, movePromoteTo = Nothing }
            , Move { moveFrom = Coordinate 'd' 4, moveTo = Coordinate 'c' 5, moveType = Standard, movePromoteTo = Nothing }
            , Move { moveFrom = Coordinate 'd' 4, moveTo = Coordinate 'd' 5, moveType = Standard, movePromoteTo = Nothing }
            , Move { moveFrom = Coordinate 'd' 4, moveTo = Coordinate 'e' 5, moveType = Standard, movePromoteTo = Nothing }
            , Move { moveFrom = Coordinate 'd' 4, moveTo = Coordinate 'e' 4, moveType = Standard, movePromoteTo = Nothing }
            , Move { moveFrom = Coordinate 'd' 4, moveTo = Coordinate 'e' 3, moveType = Standard, movePromoteTo = Nothing }
            , Move { moveFrom = Coordinate 'd' 4, moveTo = Coordinate 'd' 3, moveType = Standard, movePromoteTo = Nothing }
            , Move { moveFrom = Coordinate 'd' 4, moveTo = Coordinate 'c' 3, moveType = Standard, movePromoteTo = Nothing }
            ]

        it "does not allow the white king to castle kingside when the rook is not on its home square" $
          potentialKingMoves whiteKingNoRookCastleTest { castlingRights = CastleRights True False False False } (Coordinate 'e' 1) `shouldBe`
            [ Move { moveFrom = Coordinate 'e' 1, moveTo = Coordinate 'd' 1, moveType = Standard, movePromoteTo = Nothing }
            , Move { moveFrom = Coordinate 'e' 1, moveTo = Coordinate 'd' 2, moveType = Standard, movePromoteTo = Nothing }
            , Move { moveFrom = Coordinate 'e' 1, moveTo = Coordinate 'e' 2, moveType = Standard, movePromoteTo = Nothing }
            , Move { moveFrom = Coordinate 'e' 1, moveTo = Coordinate 'f' 2, moveType = Standard, movePromoteTo = Nothing }
            , Move { moveFrom = Coordinate 'e' 1, moveTo = Coordinate 'f' 1, moveType = Standard, movePromoteTo = Nothing }
            ]

        it "does not allow the white king to castle queenside when the rook is not on its home square" $
          potentialKingMoves whiteKingNoRookCastleTest { castlingRights = CastleRights False False True False } (Coordinate 'e' 1) `shouldBe`
            [ Move { moveFrom = Coordinate 'e' 1, moveTo = Coordinate 'd' 1, moveType = Standard, movePromoteTo = Nothing }
            , Move { moveFrom = Coordinate 'e' 1, moveTo = Coordinate 'd' 2, moveType = Standard, movePromoteTo = Nothing }
            , Move { moveFrom = Coordinate 'e' 1, moveTo = Coordinate 'e' 2, moveType = Standard, movePromoteTo = Nothing }
            , Move { moveFrom = Coordinate 'e' 1, moveTo = Coordinate 'f' 2, moveType = Standard, movePromoteTo = Nothing }
            , Move { moveFrom = Coordinate 'e' 1, moveTo = Coordinate 'f' 1, moveType = Standard, movePromoteTo = Nothing }
            ]

        it "allows the black king to castle kingside, if he has the right to" $
          potentialKingMoves blackKingOOTest { castlingRights = CastleRights False True False False } (Coordinate 'e' 8) `shouldBe`
            [ Move { moveFrom = Coordinate 'e' 8, moveTo = Coordinate 'd' 8, moveType = Standard, movePromoteTo = Nothing }
            , Move { moveFrom = Coordinate 'e' 8, moveTo = Coordinate 'f' 8, moveType = Standard, movePromoteTo = Nothing }
            , Move { moveFrom = Coordinate 'e' 8, moveTo = Coordinate 'f' 7, moveType = Standard, movePromoteTo = Nothing }
            , Move { moveFrom = Coordinate 'e' 8, moveTo = Coordinate 'e' 7, moveType = Standard, movePromoteTo = Nothing }
            , Move { moveFrom = Coordinate 'e' 8, moveTo = Coordinate 'd' 7, moveType = Standard, movePromoteTo = Nothing }
            , Move { moveFrom = Coordinate 'e' 8, moveTo = Coordinate 'g' 8, moveType = Castle, movePromoteTo = Nothing }
            ]

        it "does not allow the black king to castle kingside, if he does not have the right to" $
          potentialKingMoves blackKingOOTest { castlingRights = CastleRights False False False False } (Coordinate 'e' 8) `shouldBe`
            [ Move { moveFrom = Coordinate 'e' 8, moveTo = Coordinate 'd' 8, moveType = Standard, movePromoteTo = Nothing }
            , Move { moveFrom = Coordinate 'e' 8, moveTo = Coordinate 'f' 8, moveType = Standard, movePromoteTo = Nothing }
            , Move { moveFrom = Coordinate 'e' 8, moveTo = Coordinate 'f' 7, moveType = Standard, movePromoteTo = Nothing }
            , Move { moveFrom = Coordinate 'e' 8, moveTo = Coordinate 'e' 7, moveType = Standard, movePromoteTo = Nothing }
            , Move { moveFrom = Coordinate 'e' 8, moveTo = Coordinate 'd' 7, moveType = Standard, movePromoteTo = Nothing }
            ]

        it "allows the black king to castle queenside, if he has the right to" $
          potentialKingMoves blackKingOOOTest { castlingRights = CastleRights False False False True } (Coordinate 'e' 8) `shouldBe`
            [ Move { moveFrom = Coordinate 'e' 8, moveTo = Coordinate 'd' 8, moveType = Standard, movePromoteTo = Nothing }
            , Move { moveFrom = Coordinate 'e' 8, moveTo = Coordinate 'f' 8, moveType = Standard, movePromoteTo = Nothing }
            , Move { moveFrom = Coordinate 'e' 8, moveTo = Coordinate 'f' 7, moveType = Standard, movePromoteTo = Nothing }
            , Move { moveFrom = Coordinate 'e' 8, moveTo = Coordinate 'e' 7, moveType = Standard, movePromoteTo = Nothing }
            , Move { moveFrom = Coordinate 'e' 8, moveTo = Coordinate 'd' 7, moveType = Standard, movePromoteTo = Nothing }
            , Move { moveFrom = Coordinate 'e' 8, moveTo = Coordinate 'c' 8, moveType = Castle, movePromoteTo = Nothing }
            ]

        it "does not allow the black king to castle queenside, if he does not have the right to" $
          potentialKingMoves blackKingOOOTest { castlingRights = CastleRights False False False False } (Coordinate 'e' 8) `shouldBe`
            [ Move { moveFrom = Coordinate 'e' 8, moveTo = Coordinate 'd' 8, moveType = Standard, movePromoteTo = Nothing }
            , Move { moveFrom = Coordinate 'e' 8, moveTo = Coordinate 'f' 8, moveType = Standard, movePromoteTo = Nothing }
            , Move { moveFrom = Coordinate 'e' 8, moveTo = Coordinate 'f' 7, moveType = Standard, movePromoteTo = Nothing }
            , Move { moveFrom = Coordinate 'e' 8, moveTo = Coordinate 'e' 7, moveType = Standard, movePromoteTo = Nothing }
            , Move { moveFrom = Coordinate 'e' 8, moveTo = Coordinate 'd' 7, moveType = Standard, movePromoteTo = Nothing }
            ]

        it "allows the black king to castle both kingside or queenside, if he has the option" $
          potentialKingMoves blackKingBothCastlesTest { castlingRights = CastleRights False True False True } (Coordinate 'e' 8) `shouldBe`
            [ Move { moveFrom = Coordinate 'e' 8, moveTo = Coordinate 'd' 8, moveType = Standard, movePromoteTo = Nothing }
            , Move { moveFrom = Coordinate 'e' 8, moveTo = Coordinate 'f' 8, moveType = Standard, movePromoteTo = Nothing }
            , Move { moveFrom = Coordinate 'e' 8, moveTo = Coordinate 'f' 7, moveType = Standard, movePromoteTo = Nothing }
            , Move { moveFrom = Coordinate 'e' 8, moveTo = Coordinate 'e' 7, moveType = Standard, movePromoteTo = Nothing }
            , Move { moveFrom = Coordinate 'e' 8, moveTo = Coordinate 'd' 7, moveType = Standard, movePromoteTo = Nothing }
            , Move { moveFrom = Coordinate 'e' 8, moveTo = Coordinate 'g' 8, moveType = Castle, movePromoteTo = Nothing }
            , Move { moveFrom = Coordinate 'e' 8, moveTo = Coordinate 'c' 8, moveType = Castle, movePromoteTo = Nothing }
            ]

        it "does not allow the black king to castle when he is not on his home square" $
          potentialKingMoves blackKingMovedNoOOTest { castlingRights = CastleRights True True True True } (Coordinate 'd' 4) `shouldBe`
            [ Move { moveFrom = Coordinate 'd' 4, moveTo = Coordinate 'c' 4, moveType = Standard, movePromoteTo = Nothing }
            , Move { moveFrom = Coordinate 'd' 4, moveTo = Coordinate 'c' 5, moveType = Standard, movePromoteTo = Nothing }
            , Move { moveFrom = Coordinate 'd' 4, moveTo = Coordinate 'd' 5, moveType = Standard, movePromoteTo = Nothing }
            , Move { moveFrom = Coordinate 'd' 4, moveTo = Coordinate 'e' 5, moveType = Standard, movePromoteTo = Nothing }
            , Move { moveFrom = Coordinate 'd' 4, moveTo = Coordinate 'e' 4, moveType = Standard, movePromoteTo = Nothing }
            , Move { moveFrom = Coordinate 'd' 4, moveTo = Coordinate 'e' 3, moveType = Standard, movePromoteTo = Nothing }
            , Move { moveFrom = Coordinate 'd' 4, moveTo = Coordinate 'd' 3, moveType = Standard, movePromoteTo = Nothing }
            , Move { moveFrom = Coordinate 'd' 4, moveTo = Coordinate 'c' 3, moveType = Standard, movePromoteTo = Nothing }
            ]

        it "does not allow the black king to castle kingside when the rook is not on its home square" $
          potentialKingMoves blackKingNoRookCastleTest { castlingRights = CastleRights False True False False } (Coordinate 'e' 8) `shouldBe`
            [ Move { moveFrom = Coordinate 'e' 8, moveTo = Coordinate 'd' 8, moveType = Standard, movePromoteTo = Nothing }
            , Move { moveFrom = Coordinate 'e' 8, moveTo = Coordinate 'f' 8, moveType = Standard, movePromoteTo = Nothing }
            , Move { moveFrom = Coordinate 'e' 8, moveTo = Coordinate 'f' 7, moveType = Standard, movePromoteTo = Nothing }
            , Move { moveFrom = Coordinate 'e' 8, moveTo = Coordinate 'e' 7, moveType = Standard, movePromoteTo = Nothing }
            , Move { moveFrom = Coordinate 'e' 8, moveTo = Coordinate 'd' 7, moveType = Standard, movePromoteTo = Nothing }
            ]

        it "does not allow the black king to castle queenside when the rook is not on its home square" $
          potentialKingMoves blackKingNoRookCastleTest { castlingRights = CastleRights False False False True } (Coordinate 'e' 8) `shouldBe`
            [ Move { moveFrom = Coordinate 'e' 8, moveTo = Coordinate 'd' 8, moveType = Standard, movePromoteTo = Nothing }
            , Move { moveFrom = Coordinate 'e' 8, moveTo = Coordinate 'f' 8, moveType = Standard, movePromoteTo = Nothing }
            , Move { moveFrom = Coordinate 'e' 8, moveTo = Coordinate 'f' 7, moveType = Standard, movePromoteTo = Nothing }
            , Move { moveFrom = Coordinate 'e' 8, moveTo = Coordinate 'e' 7, moveType = Standard, movePromoteTo = Nothing }
            , Move { moveFrom = Coordinate 'e' 8, moveTo = Coordinate 'd' 7, moveType = Standard, movePromoteTo = Nothing }
            ]

        it "does not allow the king to castle if the intermediate squares are occupied" $
          potentialKingMoves startingPos { castlingRights = CastleRights True False False False } (Coordinate 'e' 1) `shouldBe`
            []


    describe "potentialPawnMoves" $ do

      context "movement" $ do

        it "never produces moves off the board" $
          property $ forAll coords $ \c -> all (isOnBoard . moveTo) $ potentialPawnMoves (placePiece emptyTest (Piece Pawn White) c) c

        it "allows double-jumping from the second rank for White" $
          potentialPawnMoves startingPos { enPassantSquare = Nothing } (Coordinate 'e' 2) `shouldBe`
            [ Move { moveFrom = Coordinate 'e' 2, moveTo = Coordinate 'e' 4, moveType = Standard, movePromoteTo = Nothing }
            , Move { moveFrom = Coordinate 'e' 2, moveTo = Coordinate 'e' 3, moveType = Standard, movePromoteTo = Nothing }
            ]

        it "disallows White double-jumping from elsewhere" $
          potentialPawnMoves
            (setupGame [ (Piece Pawn White, Coordinate 'e' 6) ]) { enPassantSquare = Nothing }
            (Coordinate 'e' 6) `shouldBe`
              [ Move { moveFrom = Coordinate 'e' 6, moveTo = Coordinate 'e' 7, moveType = Standard, movePromoteTo = Nothing } ]

        it "allows double-jumping from the second rank for Black" $
          potentialPawnMoves startingPos { enPassantSquare = Nothing } (Coordinate 'e' 7) `shouldBe`
            [ Move { moveFrom = Coordinate 'e' 7, moveTo = Coordinate 'e' 5, moveType = Standard, movePromoteTo = Nothing }
            , Move { moveFrom = Coordinate 'e' 7, moveTo = Coordinate 'e' 6, moveType = Standard, movePromoteTo = Nothing }
            ]

        it "disallows Black double-jumping from elsewhere" $
          potentialPawnMoves
            (setupGame [ (Piece Pawn Black, Coordinate 'e' 3) ]) { enPassantSquare = Nothing }
            (Coordinate 'e' 3) `shouldBe`
              [ Move { moveFrom = Coordinate 'e' 3, moveTo = Coordinate 'e' 2, moveType = Standard, movePromoteTo = Nothing } ]

        it "does not allow White to advance onto an occupied square" $
          potentialPawnMoves
            (setupGame [ (Piece Pawn Black, Coordinate 'd' 5)
                       , (Piece Pawn White, Coordinate 'd' 4)
                       ]) { enPassantSquare = Nothing}
            (Coordinate 'd' 4) `shouldBe` []

        it "does not allow White to double-jump onto an occupied square" $
          potentialPawnMoves
            (setupGame [ (Piece Pawn Black, Coordinate 'd' 4)
                       , (Piece Pawn White, Coordinate 'd' 2)
                       ]) { enPassantSquare = Nothing }
            (Coordinate 'd' 2) `shouldBe`
              [ Move { moveFrom = Coordinate 'd' 2, moveTo = Coordinate 'd' 3, moveType = Standard, movePromoteTo = Nothing } ]

        it "does not allow Black to double-jump onto an occupied square" $
          potentialPawnMoves
            (setupGame [ (Piece Pawn Black, Coordinate 'd' 7)
                       , (Piece Pawn White, Coordinate 'd' 5)
                       ]) { enPassantSquare = Nothing }
            (Coordinate 'd' 7) `shouldBe`
              [ Move { moveFrom = Coordinate 'd' 7, moveTo = Coordinate 'd' 6, moveType = Standard, movePromoteTo = Nothing } ]

        it "does not allow White to double-jump when the square in front is blocked" $
          potentialPawnMoves
            (setupGame [ (Piece Pawn Black, Coordinate 'd' 3)
                       , (Piece Pawn White, Coordinate 'd' 2)
                       ]) { enPassantSquare = Nothing }
            (Coordinate 'd' 2) `shouldBe` []

        it "does not allow Black to double-jump when the square in front is blocked" $
          potentialPawnMoves
            (setupGame [ (Piece Pawn Black, Coordinate 'd' 7)
                       , (Piece Pawn White, Coordinate 'd' 6)
                       ]) { enPassantSquare = Nothing }
            (Coordinate 'd' 7) `shouldBe` []


        it "does not allow Black to advance onto an occupied square" $
          potentialPawnMoves
            (setupGame [ (Piece Pawn Black, Coordinate 'd' 5)
                       , (Piece Pawn White, Coordinate 'd' 4)
                       ]) { enPassantSquare = Nothing }
            (Coordinate 'd' 5) `shouldBe` []

      context "promotion" $ do
        it "produces four separate promotion moves when a White pawn moves to the eighth rank" $
          potentialPawnMoves (setupGame [ (Piece Pawn White, Coordinate 'e' 7) ]) (Coordinate 'e' 7) `shouldBe`
            [ Move { moveFrom = Coordinate 'e' 7, moveTo = Coordinate 'e' 8, moveType = Promotion, movePromoteTo = Just $ Piece Rook White }
            , Move { moveFrom = Coordinate 'e' 7, moveTo = Coordinate 'e' 8, moveType = Promotion, movePromoteTo = Just $ Piece Knight White }
            , Move { moveFrom = Coordinate 'e' 7, moveTo = Coordinate 'e' 8, moveType = Promotion, movePromoteTo = Just $ Piece Bishop White }
            , Move { moveFrom = Coordinate 'e' 7, moveTo = Coordinate 'e' 8, moveType = Promotion, movePromoteTo = Just $ Piece Queen White }
            ]

        it "produces four separate promotion moves when a Black pawn moves to the first rank" $
          potentialPawnMoves (setupGame [ (Piece Pawn Black, Coordinate 'e' 2) ]) (Coordinate 'e' 2) `shouldBe`
            [ Move { moveFrom = Coordinate 'e' 2, moveTo = Coordinate 'e' 1, moveType = Promotion, movePromoteTo = Just $ Piece Rook Black }
            , Move { moveFrom = Coordinate 'e' 2, moveTo = Coordinate 'e' 1, moveType = Promotion, movePromoteTo = Just $ Piece Knight Black }
            , Move { moveFrom = Coordinate 'e' 2, moveTo = Coordinate 'e' 1, moveType = Promotion, movePromoteTo = Just $ Piece Bishop Black }
            , Move { moveFrom = Coordinate 'e' 2, moveTo = Coordinate 'e' 1, moveType = Promotion, movePromoteTo = Just $ Piece Queen Black }
            ]

        it "does not allow White to capture the Black king when promoting" $
          potentialPawnMoves (setupGame [ (Piece Pawn White, Coordinate 'e' 7)
                                        , (Piece King Black, Coordinate 'e' 8)
                                        ]) (Coordinate 'e' 7) `shouldBe` []

      context "capturing" $ do

        it "allows White to capture pieces on the neighbouring NW and NE squares" $
          potentialPawnMoves
            (setupGame [ (Piece Pawn Black, Coordinate 'c' 5)
                       , (Piece Pawn Black, Coordinate 'e' 5)
                       , (Piece Pawn White, Coordinate 'd' 4)
                       ]) { enPassantSquare = Nothing }
            (Coordinate 'd' 4) `shouldBe`
              [ Move { moveFrom = Coordinate 'd' 4, moveTo = Coordinate 'd' 5, moveType = Standard, movePromoteTo = Nothing }
              , Move { moveFrom = Coordinate 'd' 4, moveTo = Coordinate 'c' 5, moveType = Capture, movePromoteTo = Nothing }
              , Move { moveFrom = Coordinate 'd' 4, moveTo = Coordinate 'e' 5, moveType = Capture, movePromoteTo = Nothing }
              ]

        it "allows Black to capture pieces on the neighbouring NW and NE squares" $
          potentialPawnMoves
            (setupGame [ (Piece Pawn White, Coordinate 'c' 4)
                       , (Piece Pawn White, Coordinate 'e' 4)
                       , (Piece Pawn Black, Coordinate 'd' 5)
                       ]) { enPassantSquare = Nothing }
            (Coordinate 'd' 5) `shouldBe`
              [ Move { moveFrom = Coordinate 'd' 5, moveTo = Coordinate 'd' 4, moveType = Standard, movePromoteTo = Nothing }
              , Move { moveFrom = Coordinate 'd' 5, moveTo = Coordinate 'c' 4, moveType = Capture, movePromoteTo = Nothing }
              , Move { moveFrom = Coordinate 'd' 5, moveTo = Coordinate 'e' 4, moveType = Capture, movePromoteTo = Nothing }
              ]

        it "does not allow White to capture its own pieces" $
          potentialPawnMoves
            (setupGame [ (Piece Pawn White, Coordinate 'c' 5)
                       , (Piece Pawn White, Coordinate 'e' 5)
                       , (Piece Pawn White, Coordinate 'd' 4)
                       ]) { enPassantSquare = Nothing }
            (Coordinate 'd' 4) `shouldBe`
              [ Move { moveFrom = Coordinate 'd' 4, moveTo = Coordinate 'd' 5, moveType = Standard, movePromoteTo = Nothing }
              ]

        it "does not allow Black to capture its own pieces" $
          potentialPawnMoves
            (setupGame [ (Piece Pawn Black, Coordinate 'c' 4)
                        , (Piece Pawn Black, Coordinate 'e' 4)
                        , (Piece Pawn Black, Coordinate 'd' 5)
                        ]) { enPassantSquare = Nothing }
            (Coordinate 'd' 5) `shouldBe`
              [ Move { moveFrom = Coordinate 'd' 5, moveTo = Coordinate 'd' 4, moveType = Standard, movePromoteTo = Nothing }
              ]

        it "only allows capturing on the 'b' file for pawns on the 'a' file" $
          potentialPawnMoves
            (setupGame [ (Piece Pawn Black, Coordinate 'b' 5)
                       , (Piece Pawn White, Coordinate 'a' 4)
                       ]) { enPassantSquare = Nothing }
            (Coordinate 'a' 4) `shouldBe`
              [ Move { moveFrom = Coordinate 'a' 4, moveTo = Coordinate 'a' 5, moveType = Standard, movePromoteTo = Nothing }
              , Move { moveFrom = Coordinate 'a' 4, moveTo = Coordinate 'b' 5, moveType = Capture, movePromoteTo = Nothing }
              ]

        it "only allows capturing on the 'g' file for pawns on the 'h' file" $
          potentialPawnMoves
            (setupGame [ (Piece Pawn Black, Coordinate 'g' 5)
                      , (Piece Pawn White, Coordinate 'h' 4)
                      ]) { enPassantSquare = Nothing }
            (Coordinate 'h' 4) `shouldBe`
              [ Move { moveFrom = Coordinate 'h' 4, moveTo = Coordinate 'h' 5, moveType = Standard, movePromoteTo = Nothing }
              , Move { moveFrom = Coordinate 'h' 4, moveTo = Coordinate 'g' 5, moveType = Capture, movePromoteTo = Nothing }
              ]

        it "allows White to en passant, if available" $
          potentialPawnMoves (whiteEnPassantTest { enPassantSquare = Just (Coordinate 'd' 6) }) (Coordinate 'e' 5) `shouldBe`
            [ Move { moveFrom = Coordinate 'e' 5, moveTo = Coordinate 'e' 6, moveType = Standard, movePromoteTo = Nothing }
            , Move { moveFrom = Coordinate 'e' 5, moveTo = Coordinate 'd' 6, moveType = EnPassant, movePromoteTo = Nothing }
            ]

        it "allows Black to en passant, if available" $
          potentialPawnMoves blackEnPassantTest { enPassantSquare = Just (Coordinate 'e' 3) } (Coordinate 'd' 4) `shouldBe`
            [ Move { moveFrom = Coordinate 'd' 4, moveTo = Coordinate 'd' 3, moveType = Standard, movePromoteTo = Nothing }
            , Move { moveFrom = Coordinate 'd' 4, moveTo = Coordinate 'e' 3, moveType = EnPassant, movePromoteTo = Nothing }
            ]

        it "only allows en passant from the correct square" $
          potentialPawnMoves
            (setupGame [ (Piece Pawn Black, Coordinate 'd' 5)
                       , (Piece Pawn White, Coordinate 'e' 5)
                       , (Piece Pawn White, Coordinate 'b' 2)
                       ]) { enPassantSquare = Just (Coordinate 'd' 6) }
            (Coordinate 'b' 2) `shouldBe`
              [ Move { moveFrom = Coordinate 'b' 2, moveTo = Coordinate 'b' 4, moveType = Standard, movePromoteTo = Nothing }
              , Move { moveFrom = Coordinate 'b' 2, moveTo = Coordinate 'b' 3, moveType = Standard, movePromoteTo = Nothing }
              ]
