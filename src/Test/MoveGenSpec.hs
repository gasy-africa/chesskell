module MoveGenSpec where

import Chess.Base

import Control.Monad

import Test.Placements

import Test.Hspec
import Test.QuickCheck

coords :: Gen Coordinate
coords = choose ('a', 'h') >>= (\x -> liftM (Coordinate x) (choose (1, 8)))

main :: IO ()
main = hspec $

  describe "potential move generation" $ do

    context "alongRay" $ do
      context "verticals" $ do
        it "returns a list of coordinates along the north vertical ray, including the destination" $
          alongRay ((Coordinate 'a' 1), (Coordinate 'a' 8)) `shouldBe`
            [ (Coordinate 'a' 2)
            , (Coordinate 'a' 3)
            , (Coordinate 'a' 4)
            , (Coordinate 'a' 5)
            , (Coordinate 'a' 6)
            , (Coordinate 'a' 7)
            , (Coordinate 'a' 8)
            ]

        it "returns a list of coordinates along the south vertical ray, including the destination" $
          alongRay ((Coordinate 'a' 8), (Coordinate 'a' 1)) `shouldBe`
            [ (Coordinate 'a' 7)
            , (Coordinate 'a' 6)
            , (Coordinate 'a' 5)
            , (Coordinate 'a' 4)
            , (Coordinate 'a' 3)
            , (Coordinate 'a' 2)
            , (Coordinate 'a' 1)
            ]

      context "horizontals" $ do
        it "returns a list of coordinates along the east horizontal ray, including the destination" $
          alongRay ((Coordinate 'a' 1), (Coordinate 'h' 1)) `shouldBe`
            [ (Coordinate 'b' 1)
            , (Coordinate 'c' 1)
            , (Coordinate 'd' 1)
            , (Coordinate 'e' 1)
            , (Coordinate 'f' 1)
            , (Coordinate 'g' 1)
            , (Coordinate 'h' 1)
            ]

        it "returns a list of coordinates along the west horizontal ray, including the destination" $
          alongRay ((Coordinate 'h' 1), (Coordinate 'a' 1)) `shouldBe`
            [ (Coordinate 'g' 1)
            , (Coordinate 'f' 1)
            , (Coordinate 'e' 1)
            , (Coordinate 'd' 1)
            , (Coordinate 'c' 1)
            , (Coordinate 'b' 1)
            , (Coordinate 'a' 1)
            ]

    context "isBlocked" $ do

      context "verticals" $ do
        it "returns True if the destination point is behind another friendly piece along the ray" $
          isBlocked (placement rookTest) ((Coordinate 'd' 5), (Coordinate 'd' 1)) `shouldBe` True

        it "returns True if the destination point is behind another enemy piece along the ray" $
          isBlocked (placement rookCaptureVerticalTest) ((Coordinate 'd' 5), (Coordinate 'd' 8)) `shouldBe` True

        it "returns False if the destination point is in front of another piece along the ray" $
          isBlocked (placement rookTest) ((Coordinate 'd' 5), (Coordinate 'd' 4)) `shouldBe` False

        it "returns False if the ray is not blocked, moving north" $
          isBlocked (placement rookTest) ((Coordinate 'd' 5), (Coordinate 'd' 8)) `shouldBe` False

        it "returns False if the ray is not blocked, moving south" $
          isBlocked (placement onlyRookTest) ((Coordinate 'd' 5), (Coordinate 'd' 3)) `shouldBe` False

        it "returns False if the destination square is occupied by an enemy piece" $
          isBlocked (placement rookCaptureVerticalTest) ((Coordinate 'd' 5), (Coordinate 'd' 7)) `shouldBe` False

      context "horizontals" $ do
        it "returns True if the destination point is behind another piece along the ray" $
          isBlocked (placement rookTest) ((Coordinate 'd' 5), (Coordinate 'h' 5)) `shouldBe` True

        it "returns True if the destination point is behind another enemy piece along the ray" $
          isBlocked (placement rookCaptureHorizontalTest) ((Coordinate 'd' 5), (Coordinate 'g' 5)) `shouldBe` True

        it "returns False if the destination point is in front of another piece along the ray" $
          isBlocked (placement rookTest) ((Coordinate 'd' 5), (Coordinate 'e' 5)) `shouldBe` False

        it "returns False if the ray is not blocked, moving west" $
          isBlocked (placement rookTest) ((Coordinate 'd' 5), (Coordinate 'a' 5)) `shouldBe` False

        it "returns False if the ray is not blocked, moving east" $
          isBlocked (placement onlyRookTest) ((Coordinate 'd' 5), (Coordinate 'h' 5)) `shouldBe` False

        it "returns False if the destination square is occupied by an enemy piece" $
          isBlocked (placement rookCaptureHorizontalTest) ((Coordinate 'd' 5), (Coordinate 'f' 5)) `shouldBe` False

      context "diagonals" $ do
        it "returns True if the destination point is behind another piece along the ray" $
          isBlocked (placement diagonalTest) ((Coordinate 'd' 5), (Coordinate 'g' 8)) `shouldBe` True

        it "returns True if the destination point is behind another piece along the ray" $
          isBlocked (placement bishopCaptureTest) ((Coordinate 'a' 1), (Coordinate 'h' 8)) `shouldBe` True

        it "returns False if the destination point is in front of another piece along the ray" $
          isBlocked (placement diagonalTest) ((Coordinate 'd' 5), (Coordinate 'e' 6)) `shouldBe` False

        it "returns False if the ray is not blocked" $
          isBlocked (placement diagonalTest) ((Coordinate 'd' 5), (Coordinate 'a' 8)) `shouldBe` False

        it "returns False if the destination square is occupied by an enemy piece" $
          isBlocked (placement bishopCaptureTest) ((Coordinate 'a' 1), (Coordinate 'd' 4)) `shouldBe` False

    context "rook moves" $ do

      --it "never produces moves off the board" $
      --  property $ forAll coords $ \c -> all (isOnBoard . snd) $ potentialRookMoves (placement emptyTest) c

      it "produces the correct set of moves without being blocked by pieces" $
        potentialRookMoves (placement onlyRookTest) (Coordinate 'd' 5) `shouldBe`
          [ ((Coordinate 'd' 5), (Coordinate 'e' 5))
          , ((Coordinate 'd' 5), (Coordinate 'c' 5))
          , ((Coordinate 'd' 5), (Coordinate 'd' 6))
          , ((Coordinate 'd' 5), (Coordinate 'd' 4))
          , ((Coordinate 'd' 5), (Coordinate 'f' 5))
          , ((Coordinate 'd' 5), (Coordinate 'b' 5))
          , ((Coordinate 'd' 5), (Coordinate 'd' 7))
          , ((Coordinate 'd' 5), (Coordinate 'd' 3))
          , ((Coordinate 'd' 5), (Coordinate 'g' 5))
          , ((Coordinate 'd' 5), (Coordinate 'a' 5))
          , ((Coordinate 'd' 5), (Coordinate 'd' 8))
          , ((Coordinate 'd' 5), (Coordinate 'd' 2))
          , ((Coordinate 'd' 5), (Coordinate 'h' 5))
          , ((Coordinate 'd' 5), (Coordinate 'd' 1))
          ]

      it "produces the correct set of moves when blocked by some pieces" $
        potentialRookMoves (placement rookTest) (Coordinate 'd' 5) `shouldBe`
          [ ((Coordinate 'd' 5), (Coordinate 'e' 5))
          , ((Coordinate 'd' 5), (Coordinate 'c' 5))
          , ((Coordinate 'd' 5), (Coordinate 'd' 6))
          , ((Coordinate 'd' 5), (Coordinate 'd' 4))
          , ((Coordinate 'd' 5), (Coordinate 'b' 5))
          , ((Coordinate 'd' 5), (Coordinate 'd' 7))
          , ((Coordinate 'd' 5), (Coordinate 'a' 5))
          , ((Coordinate 'd' 5), (Coordinate 'd' 8))
          ]

      it "produces the correct set of moves, including captures" $
        potentialRookMoves (placement rookAllCapturesTest) (Coordinate 'd' 5) `shouldBe`
          [ ((Coordinate 'd' 5), (Coordinate 'e' 5))
          , ((Coordinate 'd' 5), (Coordinate 'c' 5))
          , ((Coordinate 'd' 5), (Coordinate 'd' 6))
          , ((Coordinate 'd' 5), (Coordinate 'd' 4))
          , ((Coordinate 'd' 5), (Coordinate 'f' 5))
          , ((Coordinate 'd' 5), (Coordinate 'b' 5))
          , ((Coordinate 'd' 5), (Coordinate 'd' 7))
          , ((Coordinate 'd' 5), (Coordinate 'd' 3))
          ]


    context "bishop moves" $ do
      --it "never produces moves off the board" $
      --  property $ forAll coords $ \c -> all (isOnBoard . snd) $ potentialBishopMoves (placement emptyTest) c

      it "produces the correct set of moves without being blocked by pieces" $
        potentialBishopMoves (placement onlyBishopTest) (Coordinate 'e' 5) `shouldBe`
          [ ((Coordinate 'e' 5), (Coordinate 'd' 6))
          , ((Coordinate 'e' 5), (Coordinate 'f' 6))
          , ((Coordinate 'e' 5), (Coordinate 'f' 4))
          , ((Coordinate 'e' 5), (Coordinate 'd' 4))
          , ((Coordinate 'e' 5), (Coordinate 'c' 7))
          , ((Coordinate 'e' 5), (Coordinate 'g' 7))
          , ((Coordinate 'e' 5), (Coordinate 'g' 3))
          , ((Coordinate 'e' 5), (Coordinate 'c' 3))
          , ((Coordinate 'e' 5), (Coordinate 'b' 8))
          , ((Coordinate 'e' 5), (Coordinate 'h' 8))
          , ((Coordinate 'e' 5), (Coordinate 'h' 2))
          , ((Coordinate 'e' 5), (Coordinate 'b' 2))
          , ((Coordinate 'e' 5), (Coordinate 'a' 1))
          ]

      it "produces the correct set of moves when blocked by some pieces" $
        potentialBishopMoves (placement bishopTest) (Coordinate 'e' 5) `shouldBe`
          [ ((Coordinate 'e' 5), (Coordinate 'd' 6))
          , ((Coordinate 'e' 5), (Coordinate 'f' 6))
          , ((Coordinate 'e' 5), (Coordinate 'f' 4))
          , ((Coordinate 'e' 5), (Coordinate 'd' 4))
          , ((Coordinate 'e' 5), (Coordinate 'c' 7))
          , ((Coordinate 'e' 5), (Coordinate 'g' 3))
          , ((Coordinate 'e' 5), (Coordinate 'b' 8))
          , ((Coordinate 'e' 5), (Coordinate 'h' 2))
          ]

      it "produces the correct set of moves, including captures" $
        potentialBishopMoves (placement bishopAllCapturesTest) (Coordinate 'e' 5) `shouldBe`
          [ ((Coordinate 'e' 5), (Coordinate 'd' 6))
          , ((Coordinate 'e' 5), (Coordinate 'f' 6))
          , ((Coordinate 'e' 5), (Coordinate 'f' 4))
          , ((Coordinate 'e' 5), (Coordinate 'd' 4))
          , ((Coordinate 'e' 5), (Coordinate 'c' 7))
          , ((Coordinate 'e' 5), (Coordinate 'g' 7))
          , ((Coordinate 'e' 5), (Coordinate 'g' 3))
          , ((Coordinate 'e' 5), (Coordinate 'c' 3))
          ]

    context "knight moves" $

      it "never produces moves off the board" $
        property $ forAll coords $ \c -> all (isOnBoard . snd) $ potentialKnightMoves c

    context "pawn moves" $

      it "never produces moves off the board" $
        property $ forAll coords $ \c -> all (isOnBoard . snd) $ potentialKnightMoves c
