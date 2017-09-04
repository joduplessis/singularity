/*

Flash CS4 ActionScript 3 Tutorial by Dan Gries.

www.flashandmath.com.

This class is a simplified version of our RainDisplay class which was used to create
a display of falling and splashing particles.  Since certain aspects of the rain display
(such as the splashing of raindrops) are not needed, we have cleaned up the code to
remove these variables and methods.

*/


package com.flashandmath.dg.display {
	import com.flashandmath.dg.objects.*;
	import com.flashandmath.dg.dataStructures.*;
	import flash.geom.*;
	import flash.display.*;
	
	public class RibbonParticleDisplay extends Sprite {
				
		public var gravity:Number;
		
		//The linked list onStageList is a list of all the particles currently
		//being animated.		
		public var onStageList:LinkedList;
		//The recycleBin stores particles that are no longer part of the animation, but 
		//which can be used again when new drops are needed.
		private var recycleBin:LinkedList;
		
		public var numOnStage:Number;
		public var numInRecycleBin:Number;
		public var displayWidth:Number;
		public var displayHeight:Number;
		
		//a vector defining wind velocity:
		public var wind:Point;
				
		public var defaultInitialVelocity:Point;
		public var defaultDropThickness:Number;
		
		//the defaultDropColor is only used when drops are not randomly colored by
		//grayscale, gradient, or fully random color.
		public var defaultDropColor:uint;
		
		public var randomizeColor:Boolean;
		public var colorMethod:String;
		public var minGray:Number;
		public var maxGray:Number;
		public var _gradientColor1:uint;
		public var _gradientColor2:uint;
		public var dropLength:String;
		public var defaultDropAlpha:Number;
				
		//If drops go outside of the xRange of the viewable window, they can be
		//removed from the animation or kept in play.  If the wind is rapidly changing,
		//there is a possibility of the particles reemerging from the side, so
		//you may wish to keep the following variable set to false.
		public var removeDropsOutsideXRange:Boolean;
		
		public var removeDropsAboveCeiling:Boolean;
		public var removeDropsBelowFloor:Boolean;
		
		//These variance parameters allow for controlled random variation in
		//raindrop velocities.
		public var initialVelocityVarianceX:Number;
		public var initialVelocityVarianceY:Number;
		public var initialVelocityVariancePercent:Number;
				
		public var randomAccel:Number;
		
		
		private var displayMask:Sprite;
		private var left:Number;
		private var right:Number;
		private var top:Number;
		private var bottom:Number;
		private var r1:Number;
		private var g1:Number;
		private var b1:Number;
		private var r2:Number;
		private var g2:Number;
		private var b2:Number;
		private var param:Number;
		private var r:Number;
		private var g:Number;
		private var b:Number;
		private var outsideTest:Boolean;		
		private var variance:Number;
		private var dropX:Number;
		
		public function RibbonParticleDisplay(w = 400, h=300, useMask = true) {			
			displayWidth = w;
			displayHeight = h;
			onStageList = new LinkedList();
			recycleBin = new LinkedList();
			wind = new Point(0,0);
			defaultInitialVelocity = new Point(0,0);
			initialVelocityVarianceX = 0;
			initialVelocityVarianceY = 0;
			initialVelocityVariancePercent = 0;
								
			numOnStage = 0;
			numInRecycleBin = 0;
			
			if (useMask) {
				displayMask = new Sprite();
				displayMask.graphics.beginFill(0xFFFF00);
				displayMask.graphics.drawRect(0,0,w,h);
				displayMask.graphics.endFill();
				this.addChild(displayMask);
				this.mask = displayMask;
			}
			
			
			defaultDropColor = 0xFFFFFF;
			defaultDropThickness = 1;
			defaultDropAlpha = 1;
			gravity = 1;
			randomizeColor = true;
			colorMethod = "gray";
			minGray = 0;
			maxGray = 1;
			_gradientColor1 = 0x0000FF;
			_gradientColor2 = 0x00FFFF;
			dropLength = "short";
			
			removeDropsOutsideXRange = true;
			removeDropsAboveCeiling = false;
			removeDropsBelowFloor = true;
						
			randomAccel = 0.03
			
		}
		
		public function get gradientColor1():uint {
			return _gradientColor1;
		}
		
		public function get gradientColor2():uint {
			return _gradientColor2;
		}
		
		public function set gradientColor1(input) {
			_gradientColor1 = uint(input);
			r1 = (_gradientColor1 >>16) & 0xFF;
			g1 = (_gradientColor1 >>8) & 0xFF;
			b1 = _gradientColor1 & 0xFF;
		}
		
		public function set gradientColor2(input) {
			_gradientColor2 = uint(input);
			r2 = (_gradientColor2 >>16) & 0xFF;
			g2 = (_gradientColor2 >>8) & 0xFF;
			b2 = _gradientColor2 & 0xFF;
		}
		
		//arguments are x, y, velx, vely, color, thickness
		public function addDrop(x0:Number, y0:Number, ...args):* {
			numOnStage++;
			var drop:*; 
			var dropColor:uint;
			var dropThickness:Number;
						
			//set color
			if (args.length > 2) {
				dropColor = args[2];
			}
			else if (randomizeColor) {
				if (colorMethod == "gray") {
					param = 255*(minGray + (maxGray-minGray)*Math.random());
					dropColor = param << 16 | param << 8 | param;
				}
				if (colorMethod == "gradient") {
					param = Math.random();
					r = int(r1 + param*(r2 - r1));
					g = int(g1 + param*(g2 - g1));
					b = int(b1 + param*(b2 - b1));
					dropColor = (r << 16) | (g << 8) | b;
				}
				if (colorMethod == "random") {
					dropColor = Math.random()*0xFFFFFF;
				}
			}
			else {
				dropColor = defaultDropColor;
			}			
			
			//set thickness
			if (args.length > 3) {
				dropThickness = args[3];
			}
			else {
				dropThickness = defaultDropThickness;
			}

			//check recycle bin for available drop:
			if (recycleBin.first != null) {
				numInRecycleBin--;
				drop = recycleBin.first;
				//remove from bin
				if (drop.next != null) {
					recycleBin.first = drop.next;
					drop.next.prev = null;
				}
				else {
					recycleBin.first = null;
				}
				drop.resetPosition(x0,y0);
				drop.visible = true;
			}
			//if the recycle bin is empty, create a new drop:
			else {
				drop = new RibbonParticle(x0,y0);
				//add to display
				this.addChild(drop);
			}
			
			drop.thickness = dropThickness;
			drop.color = dropColor;
			
			//add to beginning of onStageList
			if (onStageList.first == null) {
				onStageList.first = drop;
				drop.prev = null; //may be unnecessary
				drop.next = null;
			}
			else {
				drop.next = onStageList.first;
				onStageList.first.prev = drop;  //may be unnecessary
				onStageList.first = drop;
				drop.prev = null; //may be unnecessary
			}
						
			//set initial velocity
			if (args.length < 2) {
				variance = (1+Math.random()*initialVelocityVariancePercent);
				drop.vel.x = defaultInitialVelocity.x*variance+Math.random()*initialVelocityVarianceX;
				drop.vel.y = defaultInitialVelocity.y*variance+Math.random()*initialVelocityVarianceY;
			}
			else {
				drop.vel.x = args[0];
				drop.vel.y = args[1];
			}
			
			//set alpha
			if (args.length > 4) {
				drop.alpha = args[4];
			}
			else {
				drop.alpha = defaultDropAlpha;
			}
									
			drop.lifespan = 0;
			drop.dead = false;
			
			drop.redraw();
			
			return drop;
		}
		
		public function update():void {
			var drop:* = onStageList.first; //note drop is untyped
			var nextDrop:*;
			while (drop != null) {
				//before lists are altered, record next drop
				nextDrop = drop.next;
				//move all drops. For each drop in onStageList:
				
				drop.lifespan++;
														
				//record lastPos
				drop.lastPos.x = drop.pos.x;
				drop.lastPos.y = drop.pos.y;
				
				//update vel
				drop.vel.y += gravity + randomAccel*(2*Math.random()-1);
				drop.vel.x += randomAccel*(2*Math.random()-1);
				//we also allow separately assigned accel property to affect velocity
				drop.vel.x += drop.accel.x;
				drop.vel.y += drop.accel.y;
				
				//update position pos
				drop.pos.x += drop.vel.x + wind.x;
				drop.pos.y += drop.vel.y + wind.y;
				
				outsideTest = false;
				
				//if drop offstage, add to recycle bin, make invisible
				if (removeDropsOutsideXRange) {
					outsideTest ||= (drop.pos.x + drop.width < 0)||(drop.pos.x - drop.width > displayWidth);
				}
				
				if (removeDropsBelowFloor) {
					outsideTest ||= (drop.pos.y - drop.height > displayHeight)
				}
				
				if (removeDropsAboveCeiling) {
					outsideTest ||= (drop.pos.y + drop.height < 0)
				}
				
				if (outsideTest||drop.dead) {
					recycleDrop(drop);
				}
				
				//call redrawing function
				drop.redraw();
								
				drop = nextDrop;
			}
		}
		
		public function recycleDrop(drop:*):void {
			numOnStage--;
			numInRecycleBin++;
			
			drop.visible = false;
			
			//remove from onStageList
			if (onStageList.first == drop) {
				if (drop.next != null) {
					drop.next.prev = null;
					onStageList.first = drop.next;
				}
				else {
					onStageList.first = null;
				}
			}
			else {
				if (drop.next == null) {
					drop.prev.next = null;
				}
				else {
					drop.prev.next = drop.next;
					drop.next.prev = drop.prev;
				}
			}

			//add to recycle bin
			if (recycleBin.first == null) {
				recycleBin.first = drop;
				drop.prev = null; //may be unnecessary
				drop.next = null;
			}
			else {
				drop.next = recycleBin.first;
				recycleBin.first.prev = drop;  //may be unnecessary
				recycleBin.first = drop;
				drop.prev = null; //may be unnecessary
			}
			
			//reset accel
			drop.accel.x = 0;
			drop.accel.y = 0;
			
		}		
		
	}
}
				
		
			
