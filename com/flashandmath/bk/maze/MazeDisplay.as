/* ***********************************************************************
ActionScript 3 Tutorial by Barbara Kaskosz

http://www.flashandmath.com/

Last modified: January 30, 2011
************************************************************************ */


package com.flashandmath.bk.maze {
	
	import flash.events.Event;
	
	import flash.events.KeyboardEvent;
	
	import flash.ui.Keyboard;
	
	import flash.display.Sprite;
	
	import flash.display.CapsStyle;
	
	import flash.display.Shape;
	
	import com.flashandmath.bk.maze.MazeCell;
	
	import com.flashandmath.bk.maze.MazeDataGenerator;
	
	
	public class MazeDisplay extends Sprite {
		
		public static const MAZE_READY:String = "mazeReady";
		
		public var numRows:int;
		
		public var numCols:int;
		
		private var cellSize:Number;
		
		private var displayWidth:Number;
		
		private var displayHeight:Number;
		
		private var displayData:Array;
		
		private var mazeDataGen:MazeDataGenerator;
		
		private var ball:Shape;
		
		private var radius:Number; 
		
		private var halfSize:Number;
		
		private var speed:Number; 
		
		
		public function MazeDisplay(){
			
			ball=new Shape();
			
			this.addChild(ball);
			
		}
		
		
		
		public function createMaze(r:int,c:int,cs:Number):void {
			
			numRows=r;
			
			numCols=c;
			
			cellSize=cs;
			
			displayWidth=numCols*cellSize;
			
			displayHeight=numRows*cellSize;
			
			halfSize=Math.floor(cellSize/2);
		
			radius=halfSize-3;
			
			speed=3;
			
			mazeDataGen=new MazeDataGenerator();

            mazeDataGen.addEventListener(MazeDataGenerator.DATA_READY,onDataReady);

            mazeDataGen.createMazeData(r,c);

			
		}
		
		private function onDataReady(e:Event):void {
			
			  displayData=mazeDataGen.dataArray;
			  
			  drawBall();
	
	          drawMaze();
			  
			  dispatchEvent(new Event(MazeDisplay.MAZE_READY));
			  
			  stage.addEventListener(KeyboardEvent.KEY_DOWN,keyPressed);
	
           }
		   
	   private function keyPressed(evt:KeyboardEvent):void {
		   
		   var nextX:Number;
		   
		   var nextY:Number;
		    
		   var curCol:int=int(Math.floor(ball.x/cellSize));
		   
		   var curRow:int=int(Math.floor(ball.y/cellSize));
		  
		   var nextCol:int;
		   
		   var nextRow:int;
		   
		   if (evt.keyCode == Keyboard.RIGHT) {
			   
			     ball.y=curRow*cellSize+cellSize/2;
			   
                 nextX=ball.x+speed;
				 
				 nextCol=int(Math.floor(nextX/cellSize));
				 
				 if(nextCol==curCol && displayData[curRow][curCol].east){
					 
					 ball.x=Math.min(ball.x+speed,curCol*cellSize+cellSize/2);
				 }
				 
				 if(displayData[curRow][curCol].east==false){
					 
					 ball.x+=speed;
				 }
				 
             } else if (evt.keyCode == Keyboard.LEFT) {
				 
				 ball.y=curRow*cellSize+cellSize/2;
			   
                 nextX=ball.x-speed;
				 
				 nextCol=int(Math.floor(nextX/cellSize));
				 
				 if(nextCol==curCol && displayData[curRow][curCol].west){
					 
					 ball.x=Math.max(ball.x-speed,curCol*cellSize+cellSize/2);
				 }
				 
				 if(displayData[curRow][curCol].west==false){
					 
					 ball.x+=-speed;
				 }
				 
             } else if (evt.keyCode == Keyboard.DOWN) {
				 
				 ball.x=curCol*cellSize+cellSize/2;
			   
                 nextY=ball.y+speed;
				 
				 nextRow=int(Math.floor(nextY/cellSize));
				 
				 if(nextRow==curRow && displayData[curRow][curCol].south){
					 
					 ball.y=Math.min(ball.y+speed,curRow*cellSize+cellSize/2);
				 }
				 
				 if(displayData[curRow][curCol].south==false){
					 
					 ball.y+=speed;
				 }
			 } else if (evt.keyCode == Keyboard.UP) {
				 
				 ball.x=curCol*cellSize+cellSize/2;
			   
                 nextY=ball.y-speed;
				 
				 nextRow=int(Math.floor(nextY/cellSize));
				 
				 if(nextRow==curRow && displayData[curRow][curCol].north){
					 
					 ball.y=Math.max(ball.y-speed,curRow*cellSize+cellSize/2);
				 }
				 
				 if(displayData[curRow][curCol].north==false){
					 
					 ball.y+=-speed;
				 }
			 }
					
			evt.updateAfterEvent();
	   }
		   
	   private function drawMaze():void {
		   
		   var i:int;
		   
		   var j:int;
		   
		   var curX:Number;
		   
		   var curY:Number;
		   
		   var curRow:Array;
		   
		   var beg:int=Math.floor(Math.random()*numRows);
		   
		   var end:int=Math.floor(Math.random()*numRows);
		   
		   this.graphics.clear();
		   
		   this.graphics.lineStyle(2,0x000000);
		   
		   for(i=0;i<numRows;i++){
			   
			   curY=i*cellSize;
			   
			   curRow=displayData[i];
			   
			   for(j=0;j<numCols;j++){
				   
				   curX=j*cellSize;
				   
				   if(curRow[j].south){
					   
					   this.graphics.moveTo(curX,curY+cellSize);
					   
					   this.graphics.lineTo(curX+cellSize,curY+cellSize);
				   }
				   
				   if(curRow[j].east){
					   
					   this.graphics.moveTo(curX+cellSize,curY);
					   
					   this.graphics.lineTo(curX+cellSize,curY+cellSize);
				   }
			     
		       }
			   
		   }
		   
		  this.graphics.lineStyle(2,0x666666);
		   
		  this.graphics.drawRect(0,0,displayWidth,displayHeight);
		   
		  this.graphics.lineStyle(6, 0x006600,1.0, false, "normal", CapsStyle.NONE);
		  
		  this.graphics.moveTo(0,beg*cellSize);
					   
		  this.graphics.lineTo(0,beg*cellSize+cellSize);
		  
		  this.graphics.lineStyle(6, 0xCC0000,1.0, false, "normal", CapsStyle.NONE);
		  
		  this.graphics.moveTo(displayWidth,end*cellSize);
					   
		  this.graphics.lineTo(displayWidth,end*cellSize+cellSize);
		  
		  ball.x=cellSize/2;
		  
		  ball.y=beg*cellSize+cellSize/2;
		  
	   }
	   
	   private function drawBall():void {
		   
		  ball.graphics.clear();
		  
		  ball.graphics.lineStyle();
		  
		  ball.graphics.beginFill(0x0000CC);
		  
		  ball.graphics.drawCircle(0,0,radius);
		  
		  ball.graphics.endFill();
		   
	   }
		
	}
	
}
	