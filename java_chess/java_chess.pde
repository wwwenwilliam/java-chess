//java redo of chess (with hopefully better class design)
//2020-09-11
//version from 09-15 - castling working, possibly final verison
//todo -win condition/checkmate, undo move,

Board board = new Board();

public void setup(){
  size(800, 800);
  

  board.newBoard();
}

public void draw() {
  background(245,222,179);
  //blank board
  board.drawBoard();

  board.showMoves();
  board.showPieces();

}

public void mousePressed() {
  int clickX = (int) mouseX / 100;
  int clickY = (int) mouseY / 100;

  Piece movingPiece = board.checkPosition(clickX, clickY);

  try{
    //switches clicked piece to moving
    if(board.isTurn() == movingPiece.isSide())
      movingPiece.switchMoving();
  } catch (NullPointerException e) {
    //when user clicks on nothing
  }
}

public void mouseReleased() {
  int clickX = (int) mouseX / 100;
  int clickY = (int) mouseY / 100;

  try {
    //attempts to move piece
    if (board.checkMoving().move(clickX, clickY)) {
      //if successful
      //change turn
      board.switchTurn();
      //remove captured pieces(misleading name tbh)
      board.positionCollide(clickX, clickY);
    }
  } catch (NullPointerException e) {
    //when user tries to move a blank square
  }
}
class Bishop extends Piece{
  Bishop(int x, int y, boolean side){
    //logic
    super(new PVector(x, y), side);
    //shapes
    this.self = createShape(GROUP);
    PShape shape3 = createShape(TRIANGLE, 30, 85, 70, 85, 50, 10);
    shape3.setFill(colour);
    this.self.addChild(shape3);
    PShape shape1 = createShape(RECT, 35, 40, 30, 10);
    shape1.setFill(colour);
    this.self.addChild(shape1);
    PShape shape2 = createShape(ELLIPSE, 50, 20, 25, 25);
    shape2.setFill(colour);
    this.self.addChild(shape2);

  }

  public @Override
  boolean movingCheck(int x, int y){
    int[] numbers = {-7, -6, -5, -4, -3, -2, -1, 1, 2, 3, 4, 5, 6, 7};
    int[] numbersReverse = {7, 6, 5, 4,3, 2, 1, -1, -2, -3, -4, -5, -6, -7};

    if (board.collisionDiagonal(x, y, pos))
      return false;

    //checks top left to bottom right diagonal
    int[][] plusSlope = new int[14][2];
    for (int i=0; i<14; i++){
      plusSlope[i][0] = (int) pos.x + numbers[i];
      plusSlope[i][1] = (int) pos.y + numbers[i];
    }

    for(int[] position : plusSlope){
      if(position[0] == x & position[1] == y)
        return true;
    }

    //checks opposite diagonal
    int[][] minusSlope = new int[14][2];
    for (int i=0; i<14; i++){
      minusSlope[i][0] = (int) pos.x + numbers[i];
      minusSlope[i][1] = (int) pos.y + numbersReverse[i];
    }

    for(int[] position : minusSlope){
      if(position[0] == x & position[1] == y)
        return true;
    }

    return false;
  }

}

public class Board {
  //would have static methods but processing is weird

  public void drawBoard(){
    //draws light squares
    for (int i=0; i<8; i++){
        for (int j=0; j<8; j++){
            fill(139,69,19);
            square(100 * i, 100 + (200 * j) - (100 * (i%2)), 100);
        }
    }
  }
  public void newBoard(){
    //default chess board
    allPieces.clear();
    for(int i=0; i<8; i++){
      this.addPiece(new Pawn(i, 1, true));
      this.addPiece(new Pawn(i, 6, false));
    }
    this.addPiece(new King(4, 0, true));
    this.addPiece(new King(4, 7, false));

    this.addPiece(new Queen(3, 0, true));
    this.addPiece(new Queen(3, 7, false));

    this.addPiece(new Bishop(2, 0, true));
    this.addPiece(new Bishop(5, 0, true));
    this.addPiece(new Bishop(2, 7, false));
    this.addPiece(new Bishop(5, 7, false));

    this.addPiece(new Knight(1, 0, true));
    this.addPiece(new Knight(6, 0, true));
    this.addPiece(new Knight(1, 7, !true));
    this.addPiece(new Knight(6, 7, !true));

    this.addPiece(new Rook(0, 0, true));
    this.addPiece(new Rook(7, 0, true));
    this.addPiece(new Rook(0, 7, !true));
    this.addPiece(new Rook(7, 7, !true));

  }

  //turn related functions
  private boolean turn;

  public boolean isTurn(){
    return turn;
  }

  public void switchTurn(){
    if(turn)
        turn = false;
    else
        turn = true;
  }

  //piece related
  private ArrayList<Piece> allPieces = new ArrayList(32);

  public void addPiece(Piece piece){
    //adds piece
    allPieces.add(piece);
  }

  public void showPieces(){
    //draws pieces
    for(Piece piece : allPieces)
        piece.show();
  }

  public Piece checkPosition(int x, int y) {
    //returns piece at a position
    for (Piece piece : allPieces){
      if (piece.getPos().x == x & piece.getPos().y == y)
        return piece;
    }
    return null;
  }

  public void positionCollide(int x, int y) {
    //if two pieces are on the same square
    //one is being captured
    int out = -1;
    //finds captured piece
    for (int i=0; i<allPieces.size(); i++){
      if (allPieces.get(i).getPos().x == x && allPieces.get(i).getPos().y == y){
        if (allPieces.get(i).isSide() == turn){
          out = i;
        }
      }
    }
    //removes it
    if (out != -1)
      allPieces.remove(out);
  }

  public void showMoves(){
    //shows moveable squares
    //using showPieceMoves()
    for (Piece piece : allPieces) {
      if (piece.isMoving())
        showPieceMoves(piece);
    }
  }

  public void showPieceMoves(Piece piece){
    //highlights movable squares
    for (int i=0; i<8; i++){
        for (int j=0; j<8; j++){
            if (piece.movingCheck(i, j) & board.sameSideCheck(i, j, piece)) {
              fill(252,223,148);
              square(100 * i, 100 * j, 100);
            }
        }
    }
  }

  public boolean sameSideCheck(int x, int y, Piece moving) {
    //checks for collisions with piece from same side
    //(stops overlapping pieces)
    for(Piece piece : allPieces) {
      if (piece.isSide() == moving.isSide() & piece != moving) {
        if (piece.getPos().x == x & piece.getPos().y == y){
          return false;
        }
      }
    }
    return true;
  }

  public boolean checkCheck(int x, int y, boolean kingSide){
    //checks if an enemy piece can move to a square
    for(Piece piece : allPieces){
      if (piece.isSide() != kingSide) {
        if (!(piece instanceof King)){
          if (piece.movingCheck(x, y)){
            return true;
          }
        } else {
          //special code for king stops infinite loop
          PVector goal = new PVector(x, y);
          if (PVector.dist(piece.getPos(), goal) < 2 & PVector.dist(piece.getPos(), goal) != 0)
            return true;
        }
      }
    }
    return false;
  }

  public Piece checkMoving(){
    //returns piece that is moving
    for (Piece piece : allPieces){
      if (piece.isMoving())
        return piece;
    }
    return null;
  }

  public Piece getPiece(int i){
    //for testing
    return allPieces.get(i);
  }

  public boolean collisionStraight(int x, int y, PVector pos){
    //detects collisions in a straight line
    int[] positives = {1, 2, 3, 4, 5, 6, 7};
    int[] negatives = {-1, -2, -3, -4, -5, -6, -7};


    for (Piece piece : allPieces){
      //checks for self
      if (pos.x == piece.getPos().x & pos.y == piece.getPos().y) continue;
      //horizontal
      if (pos.y == y & pos.y == piece.getPos().y){
        //left
        for (int num : positives){
          if (pos.x + num > piece.getPos().x & pos.x + num == x & piece.getPos().x > pos.x)
            return true;
        }
        //right
        for (int num : negatives){
          if (pos.x + num < piece.getPos().x & pos.x + num == x & piece.getPos().x < pos.x)
            return true;
        }
      }
      //vertical
      if (pos.x == x & pos.x == piece.getPos().x){
        //down
        for (int num : positives) {
          if (pos.y + num > piece.getPos().y & pos.y + num == y & piece.getPos().y > pos.y)
            return true;
        }
        //up
        for (int num : negatives) {
          if (pos.y + num < piece.getPos().y & pos.y + num == y & piece.getPos().y < pos.y)
            return true;
        }
      }
    }
    return false;
  }

  public boolean collisionDiagonal(int x, int y, PVector pos){
    //detects diagonal collisions

    //could be done with for loop but whatever
    int[] positives = {1,2,3,4,5,6,7};
    int[] negatives = {-1,-2,-3,-4,-5,-6,-7};

    for(Piece piece : allPieces){
      //down-left

      int[][] downLeft = new int[7][2];
      for(int i=0; i<7; i++){
         downLeft[i][0] = (int) pos.x + positives[i];
         downLeft[i][1] = (int) pos.y + positives[i];
      }

      boolean after = false;
      for(int[] index : downLeft){
        if (index[0] == piece.getPos().x & index[1] == piece.getPos().y) {
          after = true;
          continue;
        }

        if (index[0] == x & index[1] == y & after){
          //System.out.println(index[0] + " " + index[1]);
          return true;
        }
      }



      //up-right
      int[][] upRight = new int[7][2];
      for(int i=0; i<7; i++){
         upRight[i][0] = (int) pos.x + negatives[i];
         upRight[i][1] = (int) pos.y + negatives[i];
      }

      after = false;
      for(int[] index : upRight){
        if (index[0] == piece.getPos().x & index[1] == piece.getPos().y) {
          after = true;
          continue;
        }

        if (index[0] == x & index[1] == y & after){
          //System.out.println(index[0] + " " + index[1]);
          return true;
        }
      }

      //up-left
      int[][] upLeft = new int[7][2];
      for(int i=0; i<7; i++){
         upLeft[i][0] = (int) pos.x + positives[i];
         upLeft[i][1] = (int) pos.y + negatives[i];
      }

      after = false;
      for(int[] index : upLeft){
        if (index[0] == piece.getPos().x & index[1] == piece.getPos().y) {
          after = true;
          continue;
        }

        if (index[0] == x & index[1] == y & after){
          //System.out.println(index[0] + " " + index[1]);
          return true;
        }
      }

      //down-right
      int[][] downRight = new int[7][2];
      for(int i=0; i<7; i++){
         downRight[i][0] = (int) pos.x + negatives[i];
         downRight[i][1] = (int) pos.y + positives[i];
      }

      after = false;
      for(int[] index : downRight){
        if (index[0] == piece.getPos().x & index[1] == piece.getPos().y) {
          after = true;
          continue;
        }

        if (index[0] == x & index[1] == y & after){
          //System.out.println(index[0] + " " + index[1]);
          return true;
        }
      }



    }

    return false;
  }


}
class King extends Piece{
  King(int x, int y, boolean side){
    //logic
    super(new PVector(x, y), side);
    //shape
    this.self = createShape(GROUP);
    PShape king1 = createShape(TRIANGLE, 30, 85, 70, 85, 50, 10);
    king1.setFill(colour);
    this.self.addChild(king1);
    PShape king2 = createShape(RECT, 35, 20, 30, 10);
    king2.setFill(colour);
    this.self.addChild(king2);
  }

  public @Override
  boolean movingCheck(int x, int y){
    PVector goal = new PVector(x, y);

    //normal moves
    if (PVector.dist(pos, goal) < 2 & PVector.dist(pos, goal) != 0 & !board.checkCheck(x, y, side))
      return true;

    //castling
    Rook castleRook;
    //black
    if (side){
      //kingside
      if (first && x == 6 & y == 0){
        //checks for pieces in between
        if(board.checkPosition(5, 0) == null & board.checkPosition(6, 0) == null){
          //checks to see if king moves through attacked square
          if (!(board.checkCheck(4, 0, side) || board.checkCheck(5, 0, side) || board.checkCheck(6, 0, side))){
            //checks if rook is in corner
            if (board.checkPosition(7, 0) instanceof Rook){
              castleRook = (Rook) board.checkPosition(7, 0);
              try{
                if(castleRook.isFirst()){
                  return true;
                }
              }catch(NullPointerException e) {
                //rook is not in corner
              }
            }
          }
        }//queenside
      } else if (first && x == 2 & y == 0){
        if(board.checkPosition(1, 0) == null & board.checkPosition(2, 0) == null & board.checkPosition(3, 0) == null){
          if (!(board.checkCheck(2, 0, side) || board.checkCheck(3, 0, side) || board.checkCheck(4, 0, side))){
            if (board.checkPosition(0, 0) instanceof Rook){
              castleRook = (Rook) board.checkPosition(7, 0);
              try{
                if(castleRook.isFirst()){
                  return true;
                }
              }catch(NullPointerException e) {}
            }
          }

        }
      }

    }else {
      //white
      if (first && x == 6 & y == 7){
        if(board.checkPosition(5, 7) == null & board.checkPosition(6, 7) == null){
          if (!(board.checkCheck(4, 7, side) || board.checkCheck(5, 7, side) || board.checkCheck(6, 7, side))){
            if (board.checkPosition(7, 7) instanceof Rook){
              castleRook = (Rook) board.checkPosition(7, 7);
              try{
                if(castleRook.isFirst()){
                  return true;
                }
              }catch(NullPointerException e) {}
            }
          }
        }//queenside
      } else if (first && x == 2 & y == 7){
        if(board.checkPosition(1, 7) == null & board.checkPosition(2, 7) == null & board.checkPosition(3, 7) == null){
          if (!(board.checkCheck(2, 7, side) || board.checkCheck(3, 7, side) || board.checkCheck(4, 7, side))){
            if (board.checkPosition(0, 7) instanceof Rook){
              castleRook = (Rook) board.checkPosition(0, 7);
              try{
                if(castleRook.isFirst()){
                  return true;
                }
              }catch(NullPointerException e) {}
            }
          }
        }
      }

    }
    return false;
  }

}
class Knight extends Piece{
  Knight(int x, int y, boolean side){
    //logic
    super(new PVector(x, y), side);
    //shape
    this.self = createShape(GROUP);
    PShape knight1 = createShape(TRIANGLE, 50, 20, 20, 90, 80, 90);
    knight1.setFill(colour);
    this.self.addChild(knight1);
    PShape knight2 = createShape(TRIANGLE, 15, 25, 75, 5, 75, 45);
    knight2.setFill(colour);
    this.self.addChild(knight2);
  }

  public @Override
  boolean movingCheck(int x, int y){
    if (pos.y + 2 == y || pos.y - 2 == y){
      if (pos.x + 1 ==x || pos.x -1==x)
        return true;
    }
    if (pos.x + 2 == x || pos.x - 2 == x){
      if (pos.y + 1 ==y || pos.y -1==y)
        return true;
    }
    return false;
  }

}
class Pawn extends Piece{
  Pawn(int x, int y, boolean side){
    //logic
    super(new PVector(x, y), side);
    //shape
    this.self = createShape(GROUP);
    PShape pawn2 = createShape(TRIANGLE, 50, 20, 20, 90, 80, 90);
    pawn2.setFill(colour);
    this.self.addChild(pawn2);
    PShape pawn1 = createShape(ELLIPSE, 50, 30, 35, 35);
    pawn1.setFill(colour);
    this.self.addChild(pawn1);
  }

  public @Override
  boolean movingCheck(int x, int y){
    if (side) {
      //white
      if (x == pos.x & y == pos.y +1){
        //normal
        if (board.checkPosition((int)pos.x, (int)pos.y + 1) == null){
          return true;
        }
      } else if (x == pos.x + 1 & y == pos.y + 1){
        //capture
        if (board.checkPosition((int)pos.x + 1, (int)pos.y + 1) != null){
          return true;
        }
      } else if (x == pos.x - 1 & y == pos.y + 1){
        //also capture
        if (board.checkPosition((int)pos.x - 1, (int)pos.y + 1) != null){
          return true;
        }
      } else if (x == pos.x & y == pos.y +2 & first){
        //weird first turn two step thing
        if (board.checkPosition((int)pos.x, (int)pos.y + 2) == null){
          return true;
        }
      }
    } else {
      //black
      if (x == pos.x & y == pos.y -1){
        if (board.checkPosition((int)pos.x, (int)pos.y - 1) == null){
          return true;
        }
      } else if (x == pos.x + 1 & y == pos.y - 1){
        if (board.checkPosition((int)pos.x + 1, (int)pos.y - 1) != null){
          return true;
        }
      } else if (x == pos.x - 1 & y == pos.y - 1){
        if (board.checkPosition((int)pos.x - 1, (int)pos.y - 1) != null){
          return true;
        }
      } else if (x == pos.x & y == pos.y -2 & first){
        //weird first turn two step thing
        if (board.checkPosition((int)pos.x, (int)pos.y - 2) == null){
          return true;
        }
      }

    }

    return false;
  }

}

abstract class Piece{
  int colour;
  boolean side; //true - black , false - white
  PShape self;
  PVector pos;
  boolean moving;
  boolean first = true;

  Piece(PVector pos, boolean side){
    //all pieces call this to init logic
    this.pos = pos;
    this.side = side;
    this.moving = false;

    if (side)
      colour = color(0);
    else
      colour = color(255);
  }

  public PVector getPos(){
    return pos;
  }

  public void show(){
    //draws shape
    if (moving)
      shape(self, mouseX-50, mouseY-50);
    else
      shape(self, pos.x * 100, pos.y * 100);
  }

  //method to check for valid move
  public abstract boolean movingCheck(int x, int y);

  //moves pieces when valid move
  public boolean move(int x, int y) {
    //if move is valid
    if(this.movingCheck(x, y) & board.sameSideCheck(x, y, this))  {
      //special code for castling
      if(this instanceof King){
        PVector goal = new PVector(x, y);
        if (!(PVector.dist(pos, goal) < 2 & PVector.dist(pos, goal) != 0 & !board.checkCheck(x, y, side))) {
          //moves rook
          Rook castleRook;
          if(side){
            if (x == 6 & y == 0){
              castleRook = (Rook) board.checkPosition(7, 0);
              castleRook.setPos(5, 0);
            } else if (x == 2 & y == 0){
              castleRook = (Rook) board.checkPosition(0, 0);
              castleRook.setPos(3, 0);
            }
          } else{
            if (x == 6 & y == 7){
              castleRook = (Rook) board.checkPosition(7, 7);
              castleRook.setPos(5, 7);
            } else if (x == 2 & y == 7){
              castleRook = (Rook) board.checkPosition(0, 7);
              castleRook.setPos(3, 7);
            }
          }
        }
      }
      //normal moving code
      pos.x = x;
      pos.y = y;
      this.switchMoving();
      this.switchFirst();
      return true;
    }
    //if failed valid move check
    this.switchMoving();
    return false;
  }


  public void switchMoving() {
    if (moving)
      moving = false;
    else
      moving = true;
  }

  public boolean isSide() {
    return side;
  }

  public boolean isMoving() {
    return moving;
  }

  public void switchFirst(){
    first = false;
  }



}
class Queen extends Piece{
  Queen(int x, int y, boolean side){
    //logic
    super(new PVector(x, y), side);
    //shape
    this.self = createShape(GROUP);
    PShape queen1 = createShape(TRIANGLE, 30, 85, 70, 85, 50, 10);
    queen1.setFill(colour);
    this.self.addChild(queen1);
    PShape queen2 = createShape(TRIANGLE, 50, 5, 40, 25, 60, 25);
    queen2.setFill(colour);
    this.self.addChild(queen2);
  }

  public @Override
  boolean movingCheck(int x, int y){
    //combination of bishop and rook code
    {
      //bishop code
      int[] numbers = {-7, -6, -5, -4, -3, -2, -1, 1, 2, 3, 4, 5, 6, 7};
      int[] numbersReverse = {7, 6, 5, 4,3, 2, 1, -1, -2, -3, -4, -5, -6, -7};

      if (board.collisionDiagonal(x, y, pos))
        return false;

      int[][] plusSlope = new int[14][2];
      for (int i=0; i<14; i++){
        plusSlope[i][0] = (int) pos.x + numbers[i];
        plusSlope[i][1] = (int) pos.y + numbers[i];
      }

      for(int[] position : plusSlope){
        if(position[0] == x & position[1] == y)
          return true;
      }

      int[][] minusSlope = new int[14][2];
      for (int i=0; i<14; i++){
        minusSlope[i][0] = (int) pos.x + numbers[i];
        minusSlope[i][1] = (int) pos.y + numbersReverse[i];
      }

      for(int[] position : minusSlope){
        if(position[0] == x & position[1] == y)
          return true;
      }
    }

    //rook code
    {
      if (board.collisionStraight(x, y, pos))
        return false;

      int[] numbers = {-7, -6, -5, -4, -3, -2, -1, 1, 2, 3, 4, 5, 6, 7};

      int[] horizontal = new int[14];
      for (int i=0 ; i<14; i++) {
        horizontal[i] = (int) pos.y + numbers[i];
      }

      int[] vertical = new int[14];
      for (int i=0 ; i<14; i++) {
        vertical[i] = (int) pos.x + numbers[i];
      }

      if (y == pos.y) {
        for (int square : vertical) {
          if (square == x)
            return true;
        }
      }

      if (x == pos.x) {
        for (int square : horizontal) {
          if (square == y)
            return true;
        }
      }
    }

    return false;
  }
}
class Rook extends Piece{
  Rook(int x, int y, boolean side){
    super(new PVector(x, y), side);
    //init shape/colour
    this.self = createShape(GROUP);
    PShape rook1 = createShape(RECT, 25, 20, 50, 70);
    rook1.setFill(colour);
    this.self.addChild(rook1);
    PShape rook2 = createShape(RECT, 15, 10, 70, 20);
    rook2.setFill(colour);
    this.self.addChild(rook2);
  }


  public @Override
  boolean movingCheck(int x, int y){
    //checks for valid move
    if (board.collisionStraight(x, y, pos))
      return false;

    int[] numbers = {-7, -6, -5, -4, -3, -2, -1, 1, 2, 3, 4, 5, 6, 7};

    int[] horizontal = new int[14];
    for (int i=0 ; i<14; i++) {
      horizontal[i] = (int) pos.y + numbers[i];
    }

    int[] vertical = new int[14];
    for (int i=0 ; i<14; i++) {
      vertical[i] = (int) pos.x + numbers[i];
    }

    if (y == pos.y) {
      for (int square : vertical) {
        if (square == x)
          return true;
      }
    }

    if (x == pos.x) {
      for (int square : horizontal) {
        if (square == y)
          return true;
      }
    }

    return false;
  }

  public void setPos(int x, int y){
    //for castling
    pos.x = x;
    pos.y = y;
  }

  public boolean isFirst(){
    return first;
  }
}
