module MoveGenSpec where

import Chess.Base
import Chess.MoveGen

import Control.Monad

import Test.Placements

import Test.Hspec
import Test.QuickCheck

coords :: Gen Coordinate
coords = choose ('a', 'h') >>= (\x -> liftM (Coordinate x) (choose (1, 8)))

main :: IO ()
main = hspec $

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
          isBlocked (placement rookTest) (Coordinate 'd' 5, Coordinate 'd' 1) `shouldBe` True

        it "returns True if the destination point is behind another enemy piece along the ray" $
          isBlocked (placement rookCaptureVerticalTest) (Coordinate 'd' 5, Coordinate 'd' 8) `shouldBe` True

        it "returns False if the destination point is in front of another piece along the ray" $
          isBlocked (placement rookTest) (Coordinate 'd' 5, Coordinate 'd' 4) `shouldBe` False

        it "returns False if the ray is not blocked, moving north" $
          isBlocked (placement rookTest) (Coordinate 'd' 5, Coordinate 'd' 8) `shouldBe` False

        it "returns False if the ray is not blocked, moving south" $
          isBlocked (placement onlyRookTest) (Coordinate 'd' 5, Coordinate 'd' 3) `shouldBe` False

        it "returns False if the destination square is occupied by an enemy piece" $
          isBlocked (placement rookCaptureVerticalTest) (Coordinate 'd' 5, Coordinate 'd' 7) `shouldBe` False

      context "horizontals" $ do
        it "returns True if the destination point is behind another piece along the ray" $
          isBlocked (placement rookTest) (Coordinate 'd' 5, Coordinate 'h' 5) `shouldBe` True

        it "returns True if the destination point is behind another enemy piece along the ray" $
          isBlocked (placement rookCaptureHorizontalTest) (Coordinate 'd' 5, Coordinate 'g' 5) `shouldBe` True

        it "returns False if the destination point is in front of another piece along the ray" $
          isBlocked (placement rookTest) (Coordinate 'd' 5, Coordinate 'e' 5) `shouldBe` False

        it "returns False if the ray is not blocked, moving west" $
          isBlocked (placement rookTest) (Coordinate 'd' 5, Coordinate 'a' 5) `shouldBe` False

        it "returns False if the ray is not blocked, moving east" $
          isBlocked (placement onlyRookTest) (Coordinate 'd' 5, Coordinate 'h' 5) `shouldBe` False

        it "returns False if the destination square is occupied by an enemy piece" $
          isBlocked (placement rookCaptureHorizontalTest) (Coordinate 'd' 5, Coordinate 'f' 5) `shouldBe` False

      context "diagonals" $ do
        it "returns True if the destination point is behind another piece along the ray" $
          isBlocked (placement diagonalTest) (Coordinate 'd' 5, Coordinate 'g' 8) `shouldBe` True

        it "returns True if the destination point is behind another piece along the ray" $
          isBlocked (placement bishopCaptureTest) (Coordinate 'a' 1, Coordinate 'h' 8) `shouldBe` True

        it "returns False if the destination point is in front of another piece along the ray" $
          isBlocked (placement diagonalTest) (Coordinate 'd' 5, Coordinate 'e' 6) `shouldBe` False

        it "returns False if the ray is not blocked" $
          isBlocked (placement diagonalTest) (Coordinate 'd' 5, Coordinate 'a' 8) `shouldBe` False

        it "returns False if the destination square is occupied by an enemy piece" $
          isBlocked (placement bishopCaptureTest) (Coordinate 'a' 1, Coordinate 'd' 4) `shouldBe` False

    describe "potentialRookMoves" $ do

      --it "never produces moves off the board" $
      --  property $ forAll coords $ \c -> all (isOnBoard . snd) $ potentialRookMoves (placement emptyTest) c

      it "produces the correct set of moves without being blocked by pieces" $
        potentialRookMoves (placement onlyRookTest) (Coordinate 'd' 5) `shouldBe`
          [ (Coordinate 'd' 5, Coordinate 'e' 5)
          , (Coordinate 'd' 5, Coordinate 'c' 5)
          , (Coordinate 'd' 5, Coordinate 'd' 6)
          , (Coordinate 'd' 5, Coordinate 'd' 4)
          , (Coordinate 'd' 5, Coordinate 'f' 5)
          , (Coordinate 'd' 5, Coordinate 'b' 5)
          , (Coordinate 'd' 5, Coordinate 'd' 7)
          , (Coordinate 'd' 5, Coordinate 'd' 3)
          , (Coordinate 'd' 5, Coordinate 'g' 5)
          , (Coordinate 'd' 5, Coordinate 'a' 5)
          , (Coordinate 'd' 5, Coordinate 'd' 8)
          , (Coordinate 'd' 5, Coordinate 'd' 2)
          , (Coordinate 'd' 5, Coordinate 'h' 5)
          , (Coordinate 'd' 5, Coordinate 'd' 1)
          ]

      it "produces the correct set of moves when blocked by some pieces" $
        potentialRookMoves (placement rookTest) (Coordinate 'd' 5) `shouldBe`
          [ (Coordinate 'd' 5, Coordinate 'e' 5)
          , (Coordinate 'd' 5, Coordinate 'c' 5)
          , (Coordinate 'd' 5, Coordinate 'd' 6)
          , (Coordinate 'd' 5, Coordinate 'd' 4)
          , (Coordinate 'd' 5, Coordinate 'b' 5)
          , (Coordinate 'd' 5, Coordinate 'd' 7)
          , (Coordinate 'd' 5, Coordinate 'a' 5)
          , (Coordinate 'd' 5, Coordinate 'd' 8)
          ]

      it "produces the correct set of moves, including captures" $
        potentialRookMoves (placement rookAllCapturesTest) (Coordinate 'd' 5) `shouldBe`
          [ (Coordinate 'd' 5, Coordinate 'e' 5)
          , (Coordinate 'd' 5, Coordinate 'c' 5)
          , (Coordinate 'd' 5, Coordinate 'd' 6)
          , (Coordinate 'd' 5, Coordinate 'd' 4)
          , (Coordinate 'd' 5, Coordinate 'f' 5)
          , (Coordinate 'd' 5, Coordinate 'b' 5)
          , (Coordinate 'd' 5, Coordinate 'd' 7)
          , (Coordinate 'd' 5, Coordinate 'd' 3)
          ]


    describe "potentialBishopMoves" $ do
      --it "never produces moves off the board" $
      --  property $ forAll coords $ \c -> all (isOnBoard . snd) $ potentialBishopMoves (placement emptyTest) c

      it "produces the correct set of moves without being blocked by pieces" $
        potentialBishopMoves (placement onlyBishopTest) (Coordinate 'e' 5) `shouldBe`
          [ (Coordinate 'e' 5, Coordinate 'd' 6)
          , (Coordinate 'e' 5, Coordinate 'f' 6)
          , (Coordinate 'e' 5, Coordinate 'f' 4)
          , (Coordinate 'e' 5, Coordinate 'd' 4)
          , (Coordinate 'e' 5, Coordinate 'c' 7)
          , (Coordinate 'e' 5, Coordinate 'g' 7)
          , (Coordinate 'e' 5, Coordinate 'g' 3)
          , (Coordinate 'e' 5, Coordinate 'c' 3)
          , (Coordinate 'e' 5, Coordinate 'b' 8)
          , (Coordinate 'e' 5, Coordinate 'h' 8)
          , (Coordinate 'e' 5, Coordinate 'h' 2)
          , (Coordinate 'e' 5, Coordinate 'b' 2)
          , (Coordinate 'e' 5, Coordinate 'a' 1)
          ]

      it "produces the correct set of moves when blocked by some pieces" $
        potentialBishopMoves (placement bishopTest) (Coordinate 'e' 5) `shouldBe`
          [ (Coordinate 'e' 5, Coordinate 'd' 6)
          , (Coordinate 'e' 5, Coordinate 'f' 6)
          , (Coordinate 'e' 5, Coordinate 'f' 4)
          , (Coordinate 'e' 5, Coordinate 'd' 4)
          , (Coordinate 'e' 5, Coordinate 'c' 7)
          , (Coordinate 'e' 5, Coordinate 'g' 3)
          , (Coordinate 'e' 5, Coordinate 'b' 8)
          , (Coordinate 'e' 5, Coordinate 'h' 2)
          ]

      it "produces the correct set of moves, including captures" $
        potentialBishopMoves (placement bishopAllCapturesTest) (Coordinate 'e' 5) `shouldBe`
          [ (Coordinate 'e' 5, Coordinate 'd' 6)
          , (Coordinate 'e' 5, Coordinate 'f' 6)
          , (Coordinate 'e' 5, Coordinate 'f' 4)
          , (Coordinate 'e' 5, Coordinate 'd' 4)
          , (Coordinate 'e' 5, Coordinate 'c' 7)
          , (Coordinate 'e' 5, Coordinate 'g' 7)
          , (Coordinate 'e' 5, Coordinate 'g' 3)
          , (Coordinate 'e' 5, Coordinate 'c' 3)
          ]

    describe "potentialKnightMoves" $ do

      --it "never produces moves off the board" $
      --  property $ forAll coords $ \c -> all (isOnBoard . snd) $ potentialKnightMoves c

      it "produces the correct set of moves without being blocked by pieces" $
        potentialKnightMoves (placement onlyKnightTest) (Coordinate 'd' 4) `shouldBe`
          [ (Coordinate 'd' 4, Coordinate 'b' 3)
          , (Coordinate 'd' 4, Coordinate 'b' 5)
          , (Coordinate 'd' 4, Coordinate 'c' 2)
          , (Coordinate 'd' 4, Coordinate 'c' 6)
          , (Coordinate 'd' 4, Coordinate 'e' 2)
          , (Coordinate 'd' 4, Coordinate 'e' 6)
          , (Coordinate 'd' 4, Coordinate 'f' 3)
          , (Coordinate 'd' 4, Coordinate 'f' 5)
          ]

      it "produces the correct set of moves when blocked by some pieces" $
        potentialKnightMoves (placement knightTest) (Coordinate 'd' 4) `shouldBe`
          [ (Coordinate 'd' 4, Coordinate 'b' 3)
          , (Coordinate 'd' 4, Coordinate 'c' 2)
          , (Coordinate 'd' 4, Coordinate 'c' 6)
          , (Coordinate 'd' 4, Coordinate 'e' 2)
          , (Coordinate 'd' 4, Coordinate 'e' 6)
          , (Coordinate 'd' 4, Coordinate 'f' 5)
          ]

      it "can jump over pieces" $
        potentialKnightMoves (placement startingPos) (Coordinate 'b' 1) `shouldBe`
          [ (Coordinate 'b' 1, Coordinate 'a' 3)
          , (Coordinate 'b' 1, Coordinate 'c' 3)
          ]

    describe "potentialQueenMoves" $
      context "movement" $ do
        it "produces the correct set of moves without being blocked by pieces" $
          potentialQueenMoves (placement onlyQueenTest) (Coordinate 'd' 4) `shouldBe`
            [ (Coordinate 'd' 4, Coordinate 'e' 4)
            , (Coordinate 'd' 4, Coordinate 'c' 4)
            , (Coordinate 'd' 4, Coordinate 'd' 5)
            , (Coordinate 'd' 4, Coordinate 'd' 3)
            , (Coordinate 'd' 4, Coordinate 'f' 4)
            , (Coordinate 'd' 4, Coordinate 'b' 4)
            , (Coordinate 'd' 4, Coordinate 'd' 6)
            , (Coordinate 'd' 4, Coordinate 'd' 2)
            , (Coordinate 'd' 4, Coordinate 'g' 4)
            , (Coordinate 'd' 4, Coordinate 'a' 4)
            , (Coordinate 'd' 4, Coordinate 'd' 7)
            , (Coordinate 'd' 4, Coordinate 'd' 1)
            , (Coordinate 'd' 4, Coordinate 'h' 4)
            , (Coordinate 'd' 4, Coordinate 'd' 8)
            , (Coordinate 'd' 4, Coordinate 'c' 5)
            , (Coordinate 'd' 4, Coordinate 'e' 5)
            , (Coordinate 'd' 4, Coordinate 'e' 3)
            , (Coordinate 'd' 4, Coordinate 'c' 3)
            , (Coordinate 'd' 4, Coordinate 'b' 6)
            , (Coordinate 'd' 4, Coordinate 'f' 6)
            , (Coordinate 'd' 4, Coordinate 'f' 2)
            , (Coordinate 'd' 4, Coordinate 'b' 2)
            , (Coordinate 'd' 4, Coordinate 'a' 7)
            , (Coordinate 'd' 4, Coordinate 'g' 7)
            , (Coordinate 'd' 4, Coordinate 'g' 1)
            , (Coordinate 'd' 4, Coordinate 'a' 1)
            , (Coordinate 'd' 4, Coordinate 'h' 8)
            ]

        it "produces the correct set of moves when blocked by some pieces" $
          potentialQueenMoves (placement queenTest) (Coordinate 'd' 4) `shouldBe`
            [ (Coordinate 'd' 4, Coordinate 'e' 4)
            , (Coordinate 'd' 4, Coordinate 'c' 4)
            , (Coordinate 'd' 4, Coordinate 'd' 5)
            , (Coordinate 'd' 4, Coordinate 'd' 3)
            , (Coordinate 'd' 4, Coordinate 'f' 4)
            , (Coordinate 'd' 4, Coordinate 'b' 4)
            , (Coordinate 'd' 4, Coordinate 'd' 6)
            , (Coordinate 'd' 4, Coordinate 'd' 2)
            , (Coordinate 'd' 4, Coordinate 'g' 4)
            , (Coordinate 'd' 4, Coordinate 'a' 4)
            , (Coordinate 'd' 4, Coordinate 'd' 1)
            , (Coordinate 'd' 4, Coordinate 'h' 4)
            , (Coordinate 'd' 4, Coordinate 'c' 5)
            , (Coordinate 'd' 4, Coordinate 'e' 5)
            , (Coordinate 'd' 4, Coordinate 'e' 3)
            , (Coordinate 'd' 4, Coordinate 'c' 3)
            , (Coordinate 'd' 4, Coordinate 'b' 6)
            , (Coordinate 'd' 4, Coordinate 'f' 6)
            , (Coordinate 'd' 4, Coordinate 'f' 2)
            , (Coordinate 'd' 4, Coordinate 'b' 2)
            , (Coordinate 'd' 4, Coordinate 'a' 7)
            , (Coordinate 'd' 4, Coordinate 'g' 1)
            , (Coordinate 'd' 4, Coordinate 'a' 1)
            ]

        it "produces the correct set of moves, including captures" $
          potentialQueenMoves (placement queenCaptureTest) (Coordinate 'd' 4) `shouldBe`
            [ (Coordinate 'd' 4, Coordinate 'e' 4)
            , (Coordinate 'd' 4, Coordinate 'c' 4)
            , (Coordinate 'd' 4, Coordinate 'd' 5)
            , (Coordinate 'd' 4, Coordinate 'd' 3)
            , (Coordinate 'd' 4, Coordinate 'f' 4)
            , (Coordinate 'd' 4, Coordinate 'b' 4)
            , (Coordinate 'd' 4, Coordinate 'd' 6)
            , (Coordinate 'd' 4, Coordinate 'd' 2)
            , (Coordinate 'd' 4, Coordinate 'g' 4)
            , (Coordinate 'd' 4, Coordinate 'a' 4)
            , (Coordinate 'd' 4, Coordinate 'd' 7)
            , (Coordinate 'd' 4, Coordinate 'd' 1)
            , (Coordinate 'd' 4, Coordinate 'h' 4)
            , (Coordinate 'd' 4, Coordinate 'c' 5)
            , (Coordinate 'd' 4, Coordinate 'e' 5)
            , (Coordinate 'd' 4, Coordinate 'e' 3)
            , (Coordinate 'd' 4, Coordinate 'c' 3)
            , (Coordinate 'd' 4, Coordinate 'b' 6)
            , (Coordinate 'd' 4, Coordinate 'f' 6)
            , (Coordinate 'd' 4, Coordinate 'f' 2)
            , (Coordinate 'd' 4, Coordinate 'b' 2)
            , (Coordinate 'd' 4, Coordinate 'a' 7)
            , (Coordinate 'd' 4, Coordinate 'g' 7)
            , (Coordinate 'd' 4, Coordinate 'g' 1)
            , (Coordinate 'd' 4, Coordinate 'a' 1)
            ]


    describe "potentialKingMoves" $
      context "movement" $ do
        it "allows the king to move to any square in its Moore neighbourhood" $
          potentialKingMoves (placement onlyKingTest) (CastleRights False False False False) (Coordinate 'd' 4) `shouldBe`
            [ (Coordinate 'd' 4, Coordinate 'c' 4)
            , (Coordinate 'd' 4, Coordinate 'c' 5)
            , (Coordinate 'd' 4, Coordinate 'd' 5)
            , (Coordinate 'd' 4, Coordinate 'e' 5)
            , (Coordinate 'd' 4, Coordinate 'e' 4)
            , (Coordinate 'd' 4, Coordinate 'e' 3)
            , (Coordinate 'd' 4, Coordinate 'd' 3)
            , (Coordinate 'd' 4, Coordinate 'c' 3)
            ]

        it "allows the white king to castle kingside, if he has the right to" $
          potentialKingMoves (placement whiteKingOOTest) (CastleRights True False False False) (Coordinate 'e' 1) `shouldBe`
            [ (Coordinate 'e' 1, Coordinate 'd' 1)
            , (Coordinate 'e' 1, Coordinate 'd' 2)
            , (Coordinate 'e' 1, Coordinate 'e' 2)
            , (Coordinate 'e' 1, Coordinate 'f' 2)
            , (Coordinate 'e' 1, Coordinate 'f' 1)
            , (Coordinate 'e' 1, Coordinate 'g' 1)
            ]

        it "does not allow the white king to castle kingside, if he does not have the right to" $
          potentialKingMoves (placement whiteKingOOTest) (CastleRights False False False False) (Coordinate 'e' 1) `shouldBe`
            [ (Coordinate 'e' 1, Coordinate 'd' 1)
            , (Coordinate 'e' 1, Coordinate 'd' 2)
            , (Coordinate 'e' 1, Coordinate 'e' 2)
            , (Coordinate 'e' 1, Coordinate 'f' 2)
            , (Coordinate 'e' 1, Coordinate 'f' 1)
            ]

        it "allows the white king to castle queenside, if he has the right to" $
          potentialKingMoves (placement whiteKingOOOTest) (CastleRights False False True False) (Coordinate 'e' 1) `shouldBe`
            [ (Coordinate 'e' 1, Coordinate 'd' 1)
            , (Coordinate 'e' 1, Coordinate 'd' 2)
            , (Coordinate 'e' 1, Coordinate 'e' 2)
            , (Coordinate 'e' 1, Coordinate 'f' 2)
            , (Coordinate 'e' 1, Coordinate 'f' 1)
            , (Coordinate 'e' 1, Coordinate 'c' 1)
            ]

        it "does not allow the white king to castle queenside, if he does not have the right to" $
          potentialKingMoves (placement whiteKingOOOTest) (CastleRights False False False False) (Coordinate 'e' 1) `shouldBe`
            [ (Coordinate 'e' 1, Coordinate 'd' 1)
            , (Coordinate 'e' 1, Coordinate 'd' 2)
            , (Coordinate 'e' 1, Coordinate 'e' 2)
            , (Coordinate 'e' 1, Coordinate 'f' 2)
            , (Coordinate 'e' 1, Coordinate 'f' 1)
            ]

        it "allows the white king to castle both kingside or queenside, if he has the option" $
          potentialKingMoves (placement whiteKingBothCastlesTest) (CastleRights True False True False) (Coordinate 'e' 1) `shouldBe`
            [ (Coordinate 'e' 1, Coordinate 'd' 1)
            , (Coordinate 'e' 1, Coordinate 'd' 2)
            , (Coordinate 'e' 1, Coordinate 'e' 2)
            , (Coordinate 'e' 1, Coordinate 'f' 2)
            , (Coordinate 'e' 1, Coordinate 'f' 1)
            , (Coordinate 'e' 1, Coordinate 'g' 1)
            , (Coordinate 'e' 1, Coordinate 'c' 1)
            ]

        it "does not allow the white king to castle when he is not on his home square" $
          potentialKingMoves (placement whiteKingMovedNoOOTest) (CastleRights True True True True) (Coordinate 'd' 4) `shouldBe`
            [ (Coordinate 'd' 4, Coordinate 'c' 4)
            , (Coordinate 'd' 4, Coordinate 'c' 5)
            , (Coordinate 'd' 4, Coordinate 'd' 5)
            , (Coordinate 'd' 4, Coordinate 'e' 5)
            , (Coordinate 'd' 4, Coordinate 'e' 4)
            , (Coordinate 'd' 4, Coordinate 'e' 3)
            , (Coordinate 'd' 4, Coordinate 'd' 3)
            , (Coordinate 'd' 4, Coordinate 'c' 3)
            ]

        it "does not allow the white king to castle kingside when the rook is not on its home square" $
          potentialKingMoves (placement whiteKingNoRookCastleTest) (CastleRights True False False False) (Coordinate 'e' 1) `shouldBe`
            [ (Coordinate 'e' 1, Coordinate 'd' 1)
            , (Coordinate 'e' 1, Coordinate 'd' 2)
            , (Coordinate 'e' 1, Coordinate 'e' 2)
            , (Coordinate 'e' 1, Coordinate 'f' 2)
            , (Coordinate 'e' 1, Coordinate 'f' 1)
            ]

        it "does not allow the white king to castle queenside when the rook is not on its home square" $
          potentialKingMoves (placement whiteKingNoRookCastleTest) (CastleRights False False True False) (Coordinate 'e' 1) `shouldBe`
            [ (Coordinate 'e' 1, Coordinate 'd' 1)
            , (Coordinate 'e' 1, Coordinate 'd' 2)
            , (Coordinate 'e' 1, Coordinate 'e' 2)
            , (Coordinate 'e' 1, Coordinate 'f' 2)
            , (Coordinate 'e' 1, Coordinate 'f' 1)
            ]

        it "allows the black king to castle kingside, if he has the right to" $
          potentialKingMoves (placement blackKingOOTest) (CastleRights False True False False) (Coordinate 'e' 8) `shouldBe`
            [ (Coordinate 'e' 8, Coordinate 'd' 8)
            , (Coordinate 'e' 8, Coordinate 'f' 8)
            , (Coordinate 'e' 8, Coordinate 'f' 7)
            , (Coordinate 'e' 8, Coordinate 'e' 7)
            , (Coordinate 'e' 8, Coordinate 'd' 7)
            , (Coordinate 'e' 8, Coordinate 'g' 8)
            ]

        it "does not allow the black king to castle kingside, if he does not have the right to" $
          potentialKingMoves (placement blackKingOOTest) (CastleRights False False False False) (Coordinate 'e' 8) `shouldBe`
            [ (Coordinate 'e' 8, Coordinate 'd' 8)
            , (Coordinate 'e' 8, Coordinate 'f' 8)
            , (Coordinate 'e' 8, Coordinate 'f' 7)
            , (Coordinate 'e' 8, Coordinate 'e' 7)
            , (Coordinate 'e' 8, Coordinate 'd' 7)
            ]

        it "allows the black king to castle queenside, if he has the right to" $
          potentialKingMoves (placement blackKingOOOTest) (CastleRights False False False True) (Coordinate 'e' 8) `shouldBe`
            [ (Coordinate 'e' 8, Coordinate 'd' 8)
            , (Coordinate 'e' 8, Coordinate 'f' 8)
            , (Coordinate 'e' 8, Coordinate 'f' 7)
            , (Coordinate 'e' 8, Coordinate 'e' 7)
            , (Coordinate 'e' 8, Coordinate 'd' 7)
            , (Coordinate 'e' 8, Coordinate 'c' 8)
            ]

        it "does not allow the black king to castle queenside, if he does not have the right to" $
          potentialKingMoves (placement blackKingOOOTest) (CastleRights False False False False) (Coordinate 'e' 8) `shouldBe`
            [ (Coordinate 'e' 8, Coordinate 'd' 8)
            , (Coordinate 'e' 8, Coordinate 'f' 8)
            , (Coordinate 'e' 8, Coordinate 'f' 7)
            , (Coordinate 'e' 8, Coordinate 'e' 7)
            , (Coordinate 'e' 8, Coordinate 'd' 7)
            ]

        it "allows the black king to castle both kingside or queenside, if he has the option" $
          potentialKingMoves (placement blackKingBothCastlesTest) (CastleRights False True False True) (Coordinate 'e' 8) `shouldBe`
            [ (Coordinate 'e' 8, Coordinate 'd' 8)
            , (Coordinate 'e' 8, Coordinate 'f' 8)
            , (Coordinate 'e' 8, Coordinate 'f' 7)
            , (Coordinate 'e' 8, Coordinate 'e' 7)
            , (Coordinate 'e' 8, Coordinate 'd' 7)
            , (Coordinate 'e' 8, Coordinate 'g' 8)
            , (Coordinate 'e' 8, Coordinate 'c' 8)
            ]

        it "does not allow the black king to castle when he is not on his home square" $
          potentialKingMoves (placement blackKingMovedNoOOTest) (CastleRights True True True True) (Coordinate 'd' 4) `shouldBe`
            [ (Coordinate 'd' 4, Coordinate 'c' 4)
            , (Coordinate 'd' 4, Coordinate 'c' 5)
            , (Coordinate 'd' 4, Coordinate 'd' 5)
            , (Coordinate 'd' 4, Coordinate 'e' 5)
            , (Coordinate 'd' 4, Coordinate 'e' 4)
            , (Coordinate 'd' 4, Coordinate 'e' 3)
            , (Coordinate 'd' 4, Coordinate 'd' 3)
            , (Coordinate 'd' 4, Coordinate 'c' 3)
            ]

        it "does not allow the black king to castle kingside when the rook is not on its home square" $
          potentialKingMoves (placement blackKingNoRookCastleTest) (CastleRights False True False False) (Coordinate 'e' 8) `shouldBe`
            [ (Coordinate 'e' 8, Coordinate 'd' 8)
            , (Coordinate 'e' 8, Coordinate 'f' 8)
            , (Coordinate 'e' 8, Coordinate 'f' 7)
            , (Coordinate 'e' 8, Coordinate 'e' 7)
            , (Coordinate 'e' 8, Coordinate 'd' 7)
            ]

        it "does not allow the black king to castle queenside when the rook is not on its home square" $
          potentialKingMoves (placement blackKingNoRookCastleTest) (CastleRights False False False True) (Coordinate 'e' 8) `shouldBe`
            [ (Coordinate 'e' 8, Coordinate 'd' 8)
            , (Coordinate 'e' 8, Coordinate 'f' 8)
            , (Coordinate 'e' 8, Coordinate 'f' 7)
            , (Coordinate 'e' 8, Coordinate 'e' 7)
            , (Coordinate 'e' 8, Coordinate 'd' 7)
            ]

        it "does not allow the king to castle if the intermediate squares are occupied" $
          potentialKingMoves (placement startingPos) (CastleRights True False False False) (Coordinate 'e' 1) `shouldBe`
            []


    describe "potentialPawnMoves" $ do

      context "movement" $ do

        it "allows double-jumping from the second rank for White" $
          potentialPawnMoves (placement startingPos) Nothing (Coordinate 'e' 2) `shouldBe`
            [ (Coordinate 'e' 2, Coordinate 'e' 4)
            , (Coordinate 'e' 2, Coordinate 'e' 3)
            ]

        it "disallows White double-jumping from elsewhere" $
          potentialPawnMoves (placement $
            setupGame [ (Piece Pawn White, Coordinate 'e' 7) ])
                      Nothing
                      (Coordinate 'e' 7) `shouldBe`
            [ (Coordinate 'e' 7, Coordinate 'e' 8) ]

        it "allows double-jumping from the second rank for Black" $
          potentialPawnMoves (placement startingPos) Nothing (Coordinate 'e' 7) `shouldBe`
            [ (Coordinate 'e' 7, Coordinate 'e' 5)
            , (Coordinate 'e' 7, Coordinate 'e' 6)
            ]

        it "disallows Black double-jumping from elsewhere" $
          potentialPawnMoves (placement $
            setupGame [ (Piece Pawn Black, Coordinate 'e' 2) ])
                      Nothing 
                      (Coordinate 'e' 2) `shouldBe`
            [ (Coordinate 'e' 2, Coordinate 'e' 1) ]

        it "does not allow White to advance onto an occupied square" $
          potentialPawnMoves (placement $
            setupGame [ (Piece Pawn Black, Coordinate 'd' 5)
                      , (Piece Pawn White, Coordinate 'd' 4)
                      ])
                      Nothing
                      (Coordinate 'd' 4) `shouldBe` []

        it "does not allow White to double-jump onto an occupied square" $
          potentialPawnMoves (placement $
            setupGame [ (Piece Pawn Black, Coordinate 'd' 4)
                      , (Piece Pawn White, Coordinate 'd' 2)
                      ])
                      Nothing
                      (Coordinate 'd' 2) `shouldBe`
            [ (Coordinate 'd' 2, Coordinate 'd' 3) ]

        it "does not allow Black to double-jump onto an occupied square" $
          potentialPawnMoves (placement $
            setupGame [ (Piece Pawn Black, Coordinate 'd' 7)
                      , (Piece Pawn White, Coordinate 'd' 5)
                      ])
                      Nothing
                      (Coordinate 'd' 7) `shouldBe`
            [ (Coordinate 'd' 7, Coordinate 'd' 6) ]

        it "does not allow Black to advance onto an occupied square" $
          potentialPawnMoves (placement $
            setupGame [ (Piece Pawn Black, Coordinate 'd' 5)
                      , (Piece Pawn White, Coordinate 'd' 4)
                      ])
                      Nothing
                      (Coordinate 'd' 5) `shouldBe` []

      context "capturing" $ do

        it "allows White to capture pieces on the neighbouring NW and NE squares" $
          potentialPawnMoves (placement $
            setupGame [ (Piece Pawn Black, Coordinate 'c' 5)
                      , (Piece Pawn Black, Coordinate 'e' 5)
                      , (Piece Pawn White, Coordinate 'd' 4)
                      ])
                      Nothing
                      (Coordinate 'd' 4) `shouldBe`
            [ (Coordinate 'd' 4, Coordinate 'd' 5)
            , (Coordinate 'd' 4, Coordinate 'c' 5)
            , (Coordinate 'd' 4, Coordinate 'e' 5)
            ]

        it "allows Black to capture pieces on the neighbouring NW and NE squares" $
          potentialPawnMoves (placement $
            setupGame [ (Piece Pawn White, Coordinate 'c' 4)
                      , (Piece Pawn White, Coordinate 'e' 4)
                      , (Piece Pawn Black, Coordinate 'd' 5)
                      ])
                      Nothing
                      (Coordinate 'd' 5) `shouldBe`
            [ (Coordinate 'd' 5, Coordinate 'd' 4)
            , (Coordinate 'd' 5, Coordinate 'c' 4)
            , (Coordinate 'd' 5, Coordinate 'e' 4)
            ]

        it "does not allow White to capture its own pieces" $
          potentialPawnMoves (placement $
            setupGame [ (Piece Pawn White, Coordinate 'c' 5)
                      , (Piece Pawn White, Coordinate 'e' 5)
                      , (Piece Pawn White, Coordinate 'd' 4)
                      ])
                      Nothing
                      (Coordinate 'd' 4) `shouldBe`
            [ (Coordinate 'd' 4, Coordinate 'd' 5)
            ]

        it "does not allow Black to capture its own pieces" $
          potentialPawnMoves (placement $
            setupGame [ (Piece Pawn Black, Coordinate 'c' 4)
                      , (Piece Pawn Black, Coordinate 'e' 4)
                      , (Piece Pawn Black, Coordinate 'd' 5)
                      ])
                      Nothing
                      (Coordinate 'd' 5) `shouldBe`
            [ (Coordinate 'd' 5, Coordinate 'd' 4)
            ]

        it "only allows capturing on the 'b' file for pawns on the 'a' file" $
          potentialPawnMoves (placement $
            setupGame [ (Piece Pawn Black, Coordinate 'b' 5)
                      , (Piece Pawn White, Coordinate 'a' 4)
                      ])
                      Nothing
                      (Coordinate 'a' 4) `shouldBe`
            [ (Coordinate 'a' 4, Coordinate 'a' 5)
            , (Coordinate 'a' 4, Coordinate 'b' 5)
            ]

        it "only allows capturing on the 'g' file for pawns on the 'h' file" $
          potentialPawnMoves (placement $
            setupGame [ (Piece Pawn Black, Coordinate 'g' 5)
                      , (Piece Pawn White, Coordinate 'h' 4)
                      ])
                      Nothing
                      (Coordinate 'h' 4) `shouldBe`
            [ (Coordinate 'h' 4, Coordinate 'h' 5)
            , (Coordinate 'h' 4, Coordinate 'g' 5)
            ]

        it "allows White to en passant, if available" $
          potentialPawnMoves (placement $
            setupGame [ (Piece Pawn Black, Coordinate 'd' 5)
                      , (Piece Pawn White, Coordinate 'e' 5)
                      ])
                      (Just (Coordinate 'd' 6))
                      (Coordinate 'e' 5) `shouldBe`
            [ (Coordinate 'e' 5, Coordinate 'e' 6)
            , (Coordinate 'e' 5, Coordinate 'd' 6)
            ]

        it "allows Black to en passant, if available" $
          potentialPawnMoves (placement $
            setupGame [ (Piece Pawn Black, Coordinate 'd' 4)
                      , (Piece Pawn White, Coordinate 'e' 4)
                      ])
                      (Just (Coordinate 'e' 3))
                      (Coordinate 'd' 4) `shouldBe`
            [ (Coordinate 'd' 4, Coordinate 'd' 3)
            , (Coordinate 'd' 4, Coordinate 'e' 3)
            ]

        it "only allows en passant from the correct square" $
          potentialPawnMoves (placement $
            setupGame [ (Piece Pawn Black, Coordinate 'd' 5)
                      , (Piece Pawn White, Coordinate 'e' 5)
                      , (Piece Pawn White, Coordinate 'b' 2)
                      ])
                      (Just (Coordinate 'd' 6))
                      (Coordinate 'b' 2) `shouldBe`
            [ (Coordinate 'b' 2, Coordinate 'b' 4)
            , (Coordinate 'b' 2, Coordinate 'b' 3)
            ]
