module BaseSpec where

import Chess.Base
import Chess.Game

import Control.Monad.State.Lazy

import Test.Hspec
import Test.Placements

kingOpening :: RegularGame
kingOpening = RegularGame
  { placement =
    [
      [ Square { pieceOn = Just (Piece Rook White)
               , location = Coordinate 'a' 1
               }
      , Square { pieceOn = Just (Piece Knight White)
               , location = Coordinate 'b' 1
               }
      , Square { pieceOn = Just (Piece Bishop White)
               , location = Coordinate 'c' 1
               }
      , Square { pieceOn = Just (Piece Queen White)
               , location = Coordinate 'd' 1
               }
      , Square { pieceOn = Just (Piece King White)
               , location = Coordinate 'e' 1
               }
      , Square { pieceOn = Just (Piece Bishop White)
               , location = Coordinate 'f' 1
               }
      , Square { pieceOn = Just (Piece Knight White)
               , location = Coordinate 'g' 1
               }
      , Square { pieceOn = Just (Piece Rook White)
               , location = Coordinate 'h' 1
               }
      ]

    , [ Square { pieceOn = Just (Piece Pawn White)
               , location = Coordinate 'a' 2
               }
      , Square { pieceOn = Just (Piece Pawn White)
               , location = Coordinate 'b' 2
               }
      , Square { pieceOn = Just (Piece Pawn White)
               , location = Coordinate 'c' 2
               }
      , Square { pieceOn = Just (Piece Pawn White)
               , location = Coordinate 'd' 2
               }
      , Square { pieceOn = Nothing
               , location = Coordinate 'e' 2
               }
      , Square { pieceOn = Just (Piece Pawn White)
               , location = Coordinate 'f' 2
               }
      , Square { pieceOn = Just (Piece Pawn White)
               , location = Coordinate 'g' 2
               }
      , Square { pieceOn = Just (Piece Pawn White)
               , location = Coordinate 'h' 2
               }
      ]

    , [ Square { pieceOn = Nothing
               , location = Coordinate 'a' 3
               }
      , Square { pieceOn = Nothing
               , location = Coordinate 'b' 3
               }
      , Square { pieceOn = Nothing
               , location = Coordinate 'c' 3
               }
      , Square { pieceOn = Nothing
               , location = Coordinate 'd' 3
               }
      , Square { pieceOn = Nothing
               , location = Coordinate 'e' 3
               }
      , Square { pieceOn = Nothing
               , location = Coordinate 'f' 3
               }
      , Square { pieceOn = Nothing
               , location = Coordinate 'g' 3
               }
      , Square { pieceOn = Nothing
               , location = Coordinate 'h' 3
               }
      ]
    , [ Square { pieceOn = Nothing
               , location = Coordinate 'a' 4
               }
      , Square { pieceOn = Nothing
               , location = Coordinate 'b' 4
               }
      , Square { pieceOn = Nothing
               , location = Coordinate 'c' 4
               }
      , Square { pieceOn = Nothing
               , location = Coordinate 'd' 4
               }
      , Square { pieceOn = Just (Piece Pawn White)
               , location = Coordinate 'e' 4
               }
      , Square { pieceOn = Nothing
               , location = Coordinate 'f' 4
               }
      , Square { pieceOn = Nothing
               , location = Coordinate 'g' 4
               }
      , Square { pieceOn = Nothing
               , location = Coordinate 'h' 4
               }
      ]
    , [ Square { pieceOn = Nothing
               , location = Coordinate 'a' 5
               }
      , Square { pieceOn = Nothing
               , location = Coordinate 'b' 5
               }
      , Square { pieceOn = Nothing
               , location = Coordinate 'c' 5
               }
      , Square { pieceOn = Nothing
               , location = Coordinate 'd' 5
               }
      , Square { pieceOn = Nothing
               , location = Coordinate 'e' 5
               }
      , Square { pieceOn = Nothing
               , location = Coordinate 'f' 5
               }
      , Square { pieceOn = Nothing
               , location = Coordinate 'g' 5
               }
      , Square { pieceOn = Nothing
               , location = Coordinate 'h' 5
               }
      ]
    , [ Square { pieceOn = Nothing
               , location = Coordinate 'a' 6
               }
      , Square { pieceOn = Nothing
               , location = Coordinate 'b' 6
               }
      , Square { pieceOn = Nothing
               , location = Coordinate 'c' 6
               }
      , Square { pieceOn = Nothing
               , location = Coordinate 'd' 6
               }
      , Square { pieceOn = Nothing
               , location = Coordinate 'e' 6
               }
      , Square { pieceOn = Nothing
               , location = Coordinate 'f' 6
               }
      , Square { pieceOn = Nothing
               , location = Coordinate 'g' 6
               }
      , Square { pieceOn = Nothing
               , location = Coordinate 'h' 6
               }
      ]
    , [ Square { pieceOn = Just (Piece Pawn Black)
               , location = Coordinate 'a' 7
               }
      , Square { pieceOn = Just (Piece Pawn Black)
               , location = Coordinate 'b' 7
               }
      , Square { pieceOn = Just (Piece Pawn Black)
               , location = Coordinate 'c' 7
               }
      , Square { pieceOn = Just (Piece Pawn Black)
               , location = Coordinate 'd' 7
               }
      , Square { pieceOn = Just (Piece Pawn Black)
               , location = Coordinate 'e' 7
               }
      , Square { pieceOn = Just (Piece Pawn Black)
               , location = Coordinate 'f' 7
               }
      , Square { pieceOn = Just (Piece Pawn Black)
               , location = Coordinate 'g' 7
               }
      , Square { pieceOn = Just (Piece Pawn Black)
               , location = Coordinate 'h' 7}
               ]
    , [ Square { pieceOn = Just (Piece Rook Black)
               , location = Coordinate 'a' 8
               }
      , Square { pieceOn = Just (Piece Knight Black)
               , location = Coordinate 'b' 8
               }
      , Square { pieceOn = Just (Piece Bishop Black)
               , location = Coordinate 'c' 8
               }
      , Square { pieceOn = Just (Piece Queen Black)
               , location = Coordinate 'd' 8
               }
      , Square { pieceOn = Just (Piece King Black)
               , location = Coordinate 'e' 8
               }
      , Square { pieceOn = Just (Piece Bishop Black)
               , location = Coordinate 'f' 8
               }
      , Square { pieceOn = Just (Piece Knight Black)
               , location = Coordinate 'g' 8
               }
      , Square { pieceOn = Just (Piece Rook Black)
               , location = Coordinate 'h' 8}
      ]
    ]
  , activeColor     = Black
  , castlingRights  = CastleRights True True True True
  , enPassantSquare = Nothing
  , halfMoveClock   = 0
  , fullMoveNumber  = 1
  }

main :: IO ()
main = hspec $ do

  describe "isCheckmate" $ do
    it "accepts a game and a player, returning true if that player has been checkmated" $
      isCheckmate (setupGame [ (Piece King White, Coordinate 'a' 1)
                             , (Piece King Black, Coordinate 'e' 8)
                             , (Piece Queen Black, Coordinate 'h' 1)
                             , (Piece Rook Black, Coordinate 'h' 2)]) White `shouldBe` True

    it "accepts a game and a player, returning false if that player still has a legal move" $
      isCheckmate (setupGame [ (Piece King White, Coordinate 'a' 1)
                             , (Piece Queen White, Coordinate 'd' 3)
                             , (Piece King Black, Coordinate 'e' 8)
                             , (Piece Queen Black, Coordinate 'h' 1)
                             , (Piece Rook Black, Coordinate 'h' 2)]) White `shouldBe` False

  describe "isStalemate" $ do
    it "accepts a game and a player, returning true if that player has been stalemated" $
      isStalemate (setupGame [ (Piece King White, Coordinate 'f' 7)
                             , (Piece Queen White, Coordinate 'g' 6)
                             , (Piece King Black, Coordinate 'h' 8)
                             ]) { activeColor = Black } Black `shouldBe` True

    it "accepts a game and a player, returning false if that player still has a legal move" $
      isStalemate (setupGame [ (Piece King White, Coordinate 'f' 7)
                             , (Piece Queen White, Coordinate 'g' 6)
                             , (Piece King Black, Coordinate 'h' 1)
                             ]) { activeColor = Black } Black `shouldBe` False


  describe "doMove" $ do
    context "legal moves" $ do
      it "accepts standard moves and updates the game's positional state" $
        execState (doMove Nothing $ Move { moveFrom = (Coordinate 'e' 2), moveTo = (Coordinate 'e' 4), moveType = Standard }) startingPos `shouldBe` kingOpening

      it "accepts captures and removes the captured piece from the board" $
        execState (doMove Nothing $ Move { moveFrom = (Coordinate 'd' 5), moveTo = (Coordinate 'c' 4), moveType = Capture })
          (setupGame [ (Piece Pawn White, Coordinate 'c' 4)
                     , (Piece Pawn Black, Coordinate 'd' 5)
                     , (Piece King White, Coordinate 'e' 1)
                     , (Piece King Black, Coordinate 'e' 8)
                     ]) { activeColor = Black } `shouldBe` (setupGame [ (Piece Pawn Black, Coordinate 'c' 4)
                                                                      , (Piece King White, Coordinate 'e' 1)
                                                                      , (Piece King Black, Coordinate 'e' 8)]) { activeColor = White }

      it "accepts white kingside castles, updating castling rights and moving the rook" $
        execState (doMove Nothing $ Move { moveFrom = (Coordinate 'e' 1), moveTo = (Coordinate 'g' 1), moveType = Castle }) whiteKingOOTest `shouldBe`
          (setupGame [ (Piece King White, Coordinate 'g' 1)
                     , (Piece Rook White, Coordinate 'f' 1)
                     ]) { activeColor = Black
                        , castlingRights = CastleRights False True False True
                        }

      it "accepts white queenside castles, updating castling rights and moving the rook" $
        execState (doMove Nothing $ Move { moveFrom = (Coordinate 'e' 1), moveTo = (Coordinate 'c' 1), moveType = Castle }) whiteKingOOOTest `shouldBe`
          (setupGame [ (Piece King White, Coordinate 'c' 1)
                     , (Piece Rook White, Coordinate 'd' 1)
                     ]) { activeColor = Black
                        , castlingRights = CastleRights False True False True
                        }

      it "accepts black kingside castles, updating castling rights and moving the rook" $
        execState (doMove Nothing $ Move { moveFrom = (Coordinate 'e' 8), moveTo = (Coordinate 'g' 8), moveType = Castle }) blackKingOOTest `shouldBe`
          (setupGame [ (Piece King Black, Coordinate 'g' 8)
                     , (Piece Rook Black, Coordinate 'f' 8)
                     ]) { activeColor = White
                        , castlingRights = CastleRights True False True False
                        }

      it "accepts black queenside castles, updating castling rights and moving the rook" $
        execState (doMove Nothing $ Move { moveFrom = (Coordinate 'e' 8), moveTo = (Coordinate 'c' 8), moveType = Castle }) blackKingOOOTest `shouldBe`
          (setupGame [ (Piece King Black, Coordinate 'c' 8)
                     , (Piece Rook Black, Coordinate 'd' 8)
                     ]) { activeColor = White
                        , castlingRights = CastleRights True False True False
                        }

      it "allows white to promote pawns" $
        execState (doMove (Just (Piece Queen White)) $ Move { moveFrom = (Coordinate 'e' 7), moveTo = (Coordinate 'e' 8), moveType = Promotion })
          whitePromotionTest `shouldBe` 
            (setupGame [ (Piece Queen White, Coordinate 'e' 8)
                       , (Piece King White, Coordinate 'a' 1)
                       , (Piece King Black, Coordinate 'h' 1)]) { activeColor = Black }

      it "allows black to promote pawns" $
        execState (doMove (Just (Piece Queen Black)) $ Move { moveFrom = (Coordinate 'e' 2), moveTo = (Coordinate 'e' 1), moveType = Promotion })
          blackPromotionTest `shouldBe`
            (setupGame [ (Piece Queen Black, Coordinate 'e' 1)
                       , (Piece King White, Coordinate 'a' 8)
                       , (Piece King Black, Coordinate 'h' 8)]) { activeColor = White }

      it "allows white to en passant" $
        execState (doMove Nothing $ Move { moveFrom = (Coordinate 'e' 5), moveTo = (Coordinate 'd' 6), moveType = EnPassant })
          whiteEnPassantTest { activeColor = White } `shouldBe`
            (setupGame [ (Piece Pawn White, Coordinate 'd' 6)
                       , (Piece King White, Coordinate 'a' 1)
                       , (Piece King Black, Coordinate 'h' 1)]) { activeColor = Black }

      it "allows black to en passant" $
        execState (doMove Nothing $ Move { moveFrom = (Coordinate 'd' 4), moveTo = (Coordinate 'e' 3), moveType = EnPassant })
          blackEnPassantTest { activeColor = Black } `shouldBe`
            (setupGame [ (Piece Pawn Black, Coordinate 'e' 3)
                       , (Piece King White, Coordinate 'a' 1)
                       , (Piece King Black, Coordinate 'h' 1)]) { activeColor = White }

    context "illegal moves" $ do

      it "returns a value of false for illegal moves" $
        evalState (doMove Nothing $ Move { moveFrom = Coordinate 'd' 1, moveTo = (Coordinate 'd' 8), moveType = Standard })
          startingPos `shouldBe` False

      it "does not modify the game state for illegal moves" $
        execState (doMove Nothing $ Move { moveFrom = Coordinate 'd' 1, moveTo = (Coordinate 'd' 8), moveType = Standard })
          startingPos `shouldBe` startingPos

      it "does not allow black to make a move during white's turn" $
        execState (doMove Nothing $ Move { moveFrom = Coordinate 'd' 7, moveTo = Coordinate 'd' 5, moveType = Standard })
          startingPos `shouldBe` startingPos

      it "does not allow white to make a move during black's turn" $
        execState (doMove Nothing $ Move { moveFrom = Coordinate 'd' 2, moveTo = Coordinate 'd' 4, moveType = Standard })
          kingOpening `shouldBe` kingOpening

      it "returns a value of false for en passant moves when none are allowed" $
        evalState (doMove Nothing $ Move { moveFrom = Coordinate 'e' 5, moveTo = Coordinate 'd' 6, moveType = EnPassant })
          whiteEnPassantTest { activeColor = White, enPassantSquare = Nothing } `shouldBe` False

      it "does not modify the game state for en passant moves when none are allowed" $
        execState (doMove Nothing $ Move { moveFrom = Coordinate 'e' 5, moveTo = Coordinate 'd' 6, moveType = EnPassant })
          whiteEnPassantTest { activeColor = White, enPassantSquare = Nothing } `shouldBe` whiteEnPassantTest { activeColor = White, enPassantSquare = Nothing }

      it "does not allow pawn promotion if the pawn is pinned to its king" $
        execState (doMove (Just (Piece Queen White)) $ Move { moveFrom = Coordinate 'e' 7, moveTo = Coordinate 'e' 8, moveType = Promotion })
          promotionPinTest `shouldBe` promotionPinTest

      it "does not allow en passant if the capturing pawn is pinned to its king" $
        execState (doMove Nothing $ Move { moveFrom = Coordinate 'e' 5, moveTo = Coordinate 'd' 6, moveType = EnPassant })
          enPassantPinTest `shouldBe` enPassantPinTest

      context "checks" $ do

        it "does not allow the king to move into check by a queen" $
          execState (doMove Nothing $ Move { moveFrom = Coordinate 'e' 1, moveTo = Coordinate 'd' 1, moveType = Standard })
            (setupGame [ (Piece King White, Coordinate 'e' 1)
                       , (Piece King Black, Coordinate 'e' 8)
                       , (Piece Queen Black, Coordinate 'd' 8)]) `shouldBe` (setupGame [ (Piece King White, Coordinate 'e' 1)
                                                                                       , (Piece King Black, Coordinate 'e' 8)
                                                                                       , (Piece Queen Black, Coordinate 'd' 8)])

        it "returns false when the king moves into check by a queen" $
          evalState (doMove Nothing $ Move { moveFrom = Coordinate 'e' 1, moveTo = Coordinate 'd' 1, moveType = Standard })
            (setupGame [ (Piece King White, Coordinate 'e' 1)
                       , (Piece King Black, Coordinate 'e' 8)
                       , (Piece Queen Black, Coordinate 'd' 8)]) `shouldBe` False

        it "does not allow the king to move into check by a rook" $
          execState (doMove Nothing $ Move { moveFrom = Coordinate 'e' 1, moveTo = Coordinate 'd' 1, moveType = Standard })
            (setupGame [ (Piece King White, Coordinate 'e' 1)
                       , (Piece King Black, Coordinate 'e' 8)
                       , (Piece Rook Black, Coordinate 'd' 8)]) `shouldBe` (setupGame [ (Piece King White, Coordinate 'e' 1)
                                                                                      , (Piece King Black, Coordinate 'e' 8)
                                                                                      , (Piece Rook Black, Coordinate 'd' 8)])

        it "returns false when the king moves into check by a rook" $
          evalState (doMove Nothing $ Move { moveFrom = Coordinate 'e' 1, moveTo = Coordinate 'd' 1, moveType = Standard })
            (setupGame [ (Piece King White, Coordinate 'e' 1)
                       , (Piece King Black, Coordinate 'e' 8)
                       , (Piece Rook Black, Coordinate 'd' 8)]) `shouldBe` False

        it "does not allow the king to move into check by a bishop" $
          execState (doMove Nothing $ Move { moveFrom = Coordinate 'e' 1, moveTo = Coordinate 'd' 1, moveType = Standard })
            (setupGame [ (Piece King White, Coordinate 'e' 1)
                       , (Piece King Black, Coordinate 'e' 8)
                       , (Piece Bishop Black, Coordinate 'h' 5)]) `shouldBe` (setupGame [ (Piece King White, Coordinate 'e' 1)
                                                                                        , (Piece King Black, Coordinate 'e' 8)
                                                                                        , (Piece Bishop Black, Coordinate 'h' 5)])

        it "returns false when the king moves into check by a bishop" $
          evalState (doMove Nothing $ Move { moveFrom = Coordinate 'e' 1, moveTo = Coordinate 'd' 1, moveType = Standard })
            (setupGame [ (Piece King White, Coordinate 'e' 1)
                       , (Piece King Black, Coordinate 'e' 8)
                       , (Piece Bishop Black, Coordinate 'h' 5)]) `shouldBe` False

        it "does not allow the king to move into check by a knight" $
          execState (doMove Nothing $ Move { moveFrom = Coordinate 'e' 1, moveTo = Coordinate 'd' 1, moveType = Standard })
            (setupGame [ (Piece King White, Coordinate 'e' 1)
                       , (Piece King Black, Coordinate 'e' 8)
                       , (Piece Knight Black, Coordinate 'e' 3)]) `shouldBe` (setupGame [ (Piece King White, Coordinate 'e' 1)
                                                                                        , (Piece King Black, Coordinate 'e' 8)
                                                                                        , (Piece Knight Black, Coordinate 'e' 3)])

        it "returns false when the king moves into check by a knight" $
          evalState (doMove Nothing $ Move { moveFrom = Coordinate 'e' 1, moveTo = Coordinate 'd' 1, moveType = Standard })
            (setupGame [ (Piece King White, Coordinate 'e' 1)
                       , (Piece King Black, Coordinate 'e' 8)
                       , (Piece Knight Black, Coordinate 'e' 3)]) `shouldBe` False

        it "does not allow the king to move into check by a pawn" $
          execState (doMove Nothing $ Move { moveFrom = Coordinate 'e' 1, moveTo = Coordinate 'd' 1, moveType = Standard })
            (setupGame [ (Piece King White, Coordinate 'e' 1)
                       , (Piece King Black, Coordinate 'e' 8)
                       , (Piece Pawn Black, Coordinate 'e' 2)]) `shouldBe` (setupGame [ (Piece King White, Coordinate 'e' 1)
                                                                                      , (Piece King Black, Coordinate 'e' 8)
                                                                                      , (Piece Pawn Black, Coordinate 'e' 2)])

        it "returns false when the king moves into check by a pawn" $
          evalState (doMove Nothing $ Move { moveFrom = Coordinate 'e' 1, moveTo = Coordinate 'd' 1, moveType = Standard })
            (setupGame [ (Piece King White, Coordinate 'e' 1)
                       , (Piece King Black, Coordinate 'e' 8)
                       , (Piece Pawn Black, Coordinate 'e' 2)]) `shouldBe` False

        it "does not allow the king to move into check by a king" $
          execState (doMove Nothing $ Move { moveFrom = Coordinate 'e' 1, moveTo = Coordinate 'd' 1, moveType = Standard })
            (setupGame [ (Piece King White, Coordinate 'e' 1)
                       , (Piece King Black, Coordinate 'c' 2)]) `shouldBe` (setupGame [ (Piece King White, Coordinate 'e' 1)
                                                                                      , (Piece King Black, Coordinate 'c' 2)])

        it "returns false when the king moves into check by a king" $
          evalState (doMove Nothing $ Move { moveFrom = Coordinate 'e' 1, moveTo = Coordinate 'd' 1, moveType = Standard })
            (setupGame [ (Piece King White, Coordinate 'e' 1)
                       , (Piece King Black, Coordinate 'c' 2)]) `shouldBe` False

        it "does not allow the king to be captured on the next move" $
          execState (doMove Nothing $ Move { moveFrom = Coordinate 'a' 2, moveTo = Coordinate 'a' 4, moveType = Standard })
            (setupGame [ (Piece King White, Coordinate 'e' 1)
                       , (Piece Pawn White, Coordinate 'a' 2)
                       , (Piece Queen Black, Coordinate 'h' 1)
                       , (Piece King Black, Coordinate 'e' 8)]) `shouldBe` (setupGame [ (Piece King White, Coordinate 'e' 1)
                                                                                      , (Piece Pawn White, Coordinate 'a' 2)
                                                                                      , (Piece Queen Black, Coordinate 'h' 1)
                                                                                      , (Piece King Black, Coordinate 'e' 8)])

        it "returns false if the king can be captured on the next move" $
          evalState (doMove Nothing $ Move { moveFrom = Coordinate 'a' 2, moveTo = Coordinate 'a' 4, moveType = Standard })
            (setupGame [ (Piece King White, Coordinate 'e' 1)
                       , (Piece Pawn White, Coordinate 'a' 2)
                       , (Piece Queen Black, Coordinate 'h' 1)
                       , (Piece King Black, Coordinate 'e' 8)]) `shouldBe` False

        it "does not allow a piece pinned to the king to be moved" $
          execState (doMove Nothing $ Move { moveFrom = Coordinate 'e' 5, moveTo = Coordinate 'h' 5, moveType = Standard })
            discoveredCheckTest `shouldBe` discoveredCheckTest

        it "returns false if a piece pinned to the king is moved" $
          evalState (doMove Nothing $ Move { moveFrom = Coordinate 'e' 5, moveTo = Coordinate 'h' 5, moveType = Standard })
            discoveredCheckTest `shouldBe` False

        it "requires the king to move under double check" $
          execState (doMove Nothing $ Move { moveFrom = Coordinate 'h' 7, moveTo = Coordinate 'e' 4, moveType = Capture })
            doubleCheckTest `shouldBe` doubleCheckTest

        it "returns false if the king does not move under double check" $
          evalState (doMove Nothing $ Move { moveFrom = Coordinate 'h' 7, moveTo = Coordinate 'e' 4, moveType = Capture })
            doubleCheckTest `shouldBe` False

        it "does not allow the king to castle into check" $
          execState (doMove Nothing $ Move { moveFrom = Coordinate 'e' 1, moveTo = Coordinate 'g' 1, moveType = Castle })
            castleIntoCheckTest `shouldBe` castleIntoCheckTest

        it "returns false if the king castles into check" $
          evalState (doMove Nothing $ Move { moveFrom = Coordinate 'e' 1, moveTo = Coordinate 'g' 1, moveType = Castle })
            castleIntoCheckTest `shouldBe` False

        it "does not allow the white king to kingside castle through check" $
          execState (doMove Nothing $ Move { moveFrom = Coordinate 'e' 1, moveTo = Coordinate 'g' 1, moveType = Castle })
            whiteKingsideCastleThroughCheckTest `shouldBe` whiteKingsideCastleThroughCheckTest

        it "returns false if the white king kingside castles through check" $
          evalState (doMove Nothing $ Move { moveFrom = Coordinate 'e' 1, moveTo = Coordinate 'g' 1, moveType = Castle })
            whiteKingsideCastleThroughCheckTest `shouldBe` False

        it "does not allow the white king to queenside castle through check" $
          execState (doMove Nothing $ Move { moveFrom = Coordinate 'e' 1, moveTo = Coordinate 'c' 1, moveType = Castle })
            whiteQueensideCastleThroughCheckTest `shouldBe` whiteQueensideCastleThroughCheckTest

        it "returns false if the white king queenside castles through check" $
          evalState (doMove Nothing $ Move { moveFrom = Coordinate 'e' 1, moveTo = Coordinate 'c' 1, moveType = Castle })
            whiteQueensideCastleThroughCheckTest `shouldBe` False

        it "does not allow the black king to kingside castle through check" $
          execState (doMove Nothing $ Move { moveFrom = Coordinate 'e' 8, moveTo = Coordinate 'g' 8, moveType = Castle })
            blackKingsideCastleThroughCheckTest `shouldBe` blackKingsideCastleThroughCheckTest

        it "returns false if the black king kingside castles through check" $
          evalState (doMove Nothing $ Move { moveFrom = Coordinate 'e' 8, moveTo = Coordinate 'g' 8, moveType = Castle })
            blackKingsideCastleThroughCheckTest `shouldBe` False

        it "does not allow the black king to queenside castle through check" $
          execState (doMove Nothing $ Move { moveFrom = Coordinate 'e' 8, moveTo = Coordinate 'c' 8, moveType = Castle })
            blackQueensideCastleThroughCheckTest `shouldBe` blackQueensideCastleThroughCheckTest

        it "returns false if the black king queenside castles through check" $
          evalState (doMove Nothing $ Move { moveFrom = Coordinate 'e' 8, moveTo = Coordinate 'c' 8, moveType = Castle })
            blackQueensideCastleThroughCheckTest `shouldBe` False
