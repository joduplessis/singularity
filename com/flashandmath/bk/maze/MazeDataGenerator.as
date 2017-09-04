/* ***********************************************************************
ActionScript 3 Tutorial by Barbara Kaskosz

http://www.flashandmath.com/

Last modified: January 30, 2011
************************************************************************ */


package com.flashandmath.bk.maze {
	
	import flash.events.Event;
	
	import flash.events.EventDispatcher;
	
	import com.flashandmath.bk.maze.MazeCell;
	
	
	public class MazeDataGenerator extends EventDispatcher {
		
		public static const DATA_READY:String = "dataReady";
		
		public var numRows:int;
		
		public var numCols:int;
		
		private var numVisited:int;
		
		private var cellsTotal:int;
		
		private var _dataArray:Array;
		
		private var visitedList:Array;
		
		public function MazeDataGenerator(){
			
			
			
		}
		
		public function createMazeData(r:int,c:int):void {
			
			var i:int;
			
			var j:int;
			
			var curRow:int;
			
			var curCol:int;
			
			var randNeighbor:int;
			
			var curCell:MazeCell;
			
			var backArray:Array;
			
			numRows=r;
			
			numCols=c;
			
			cellsTotal=numRows*numCols;
			
			numVisited=0;
			
			visitedList=[];
			
			_dataArray=[];
			
			for(i=0;i<numRows;i++){
				
				_dataArray[i]=[];
				
				for(j=0;j<numCols;j++){
					
					_dataArray[i][j]=new MazeCell();
					
					_dataArray[i][j].row=i;
					
					_dataArray[i][j].col=j;
				}
				
			}
			
			curRow=Math.floor(Math.random()*numRows);
			
			curCol=Math.floor(Math.random()*numCols);
			
			visitedList.push([curRow,curCol]);
			
			curCell=_dataArray[curRow][curCol];
			
			curCell.visited=true;
			
			numVisited+=1;
			
			while(numVisited<cellsTotal){
			
			curCell.neighbors=[];
			
			if(curRow-1>=0 && _dataArray[curRow-1][curCol].visited==false){
				
					curCell.neighbors.push("north");
			}
			
			if(curRow+1<numRows && _dataArray[curRow+1][curCol].visited==false){
				
					curCell.neighbors.push("south");
			}
			
			if(curCol-1>=0 && _dataArray[curRow][curCol-1].visited==false){
				
					curCell.neighbors.push("west");
			}
			
			if(curCol+1<numCols && _dataArray[curRow][curCol+1].visited==false){
				
					curCell.neighbors.push("east");
			}
			
			if(curCell.neighbors.length>0){
				
				randNeighbor=Math.floor(Math.random()*curCell.neighbors.length);
				
				if(curCell.neighbors[randNeighbor]=="north"){
				   
				   curCell.north=false;
				   
				   curCell=_dataArray[curRow-1][curCol];
				   
				   curCell.south=false;
				   
				   curCell.visited=true;
				   
				   curRow=curCell.row;
				   
				   curCol=curCell.col;
				   
				   numVisited+=1;
				   
				   visitedList.push([curRow,curCol]);
				  
				   }
	
			
			else if(curCell.neighbors[randNeighbor]=="south"){
				
				   curCell.south=false;
				   
				   curCell=_dataArray[curRow+1][curCol];
				   
				   curCell.north=false;
				   
				   curCell.visited=true;
				   
				   curRow=curCell.row;
				   
				   curCol=curCell.col;
				   
				   numVisited+=1;
				   
				   visitedList.push([curRow,curCol]);
				
			}
			
			else if(curCell.neighbors[randNeighbor]=="west"){
				
				   curCell.west=false;
				   
				   curCell=_dataArray[curRow][curCol-1];
				   
				   curCell.east=false;
				   
				   curCell.visited=true;
				   
				   curRow=curCell.row;
				   
				   curCol=curCell.col;
				   
				   numVisited+=1;
				   
				   visitedList.push([curRow,curCol]);
				
			}
			
			else if(curCell.neighbors[randNeighbor]=="east"){
				
				   curCell.east=false;
				   
				   curCell=_dataArray[curRow][curCol+1];
				   
				   curCell.west=false;
				   
				   curCell.visited=true;
				   
				   curRow=curCell.row;
				   
				   curCol=curCell.col;
				   
				   numVisited+=1;
				   
				   visitedList.push([curRow,curCol]);
				
			}
			
			}
			
			else {
				
				backArray=visitedList.pop();
				
				curRow=backArray[0];
				
				curCol=backArray[1];
				
				curCell=_dataArray[curRow][curCol];
			}
			
			}
			
			if(numVisited==cellsTotal){
				
				dispatchEvent(new Event(MazeDataGenerator.DATA_READY));
				
			}
			
			
		}
		
		public function get dataArray():Array {
			
			return _dataArray;
			
		}
		
		
		
	}
	
}
	