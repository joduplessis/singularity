/* ***********************************************************************
ActionScript 3 Tutorial by Barbara Kaskosz

http://www.flashandmath.com/

Last modified: January 30, 2011
************************************************************************ */


package com.flashandmath.bk.maze {
	
	public class MazeCell {
		
		public var visited:Boolean;
		
		public var north:Boolean;
		
		public var east:Boolean;
		
		public var south:Boolean;
		
		public var west:Boolean;
		
		public var row:int;
		
		public var col:int;
		
		public var neighbors:Array;
		
	
		public function MazeCell(){
			
			visited=false;
			
			south=true;
			
			north=true;
			
			west=true;
			
			east=true;
			
		}
		
		
		
	}
	
}
	