/*

Flash CS4 ActionScript 3 Tutorial by Dan Gries.

www.flashandmath.com.

*/

package com.flashandmath.dg.objects {
	import flash.display.Sprite;
	import flash.geom.*;
	
	public class RibbonParticle extends Sprite {
				
		public var lifespan:int;
				
		public var thickness:Number;
		
		public var pos:Point;		
		public var lastPos:Point;
		public var vel:Point;
		public var accel:Point;
		
		public var color:uint;
		
		public var radiusWhenStill:Number;
		
		public var attack:Number;
		public var hold:Number;
		public var decay:Number;
		public var rInit:Number;
		public var rHold:Number;
		public var rLast:Number;
		
		public var ribbonAlpha:Number;
		
		
		public var rotationInc:Number;
		
		//The following attributes are for the purposes of creating a
		//linked list of RibbonParticle instances.
		public var next:RibbonParticle;
		public var prev:RibbonParticle;
		
		public var dotRadius:Number;
		public var dotRadiusVariance:Number;
		public var dead:Boolean;
		
		private var angle:Number;
		private var cos:Number;
		private var sin:Number;
		private var rad:Number;		
		private var lastRad:Number;
		private var v1x:Number;
		private var v1y:Number;
		private var _maxRotation:Number;
		
		public function RibbonParticle(x0=0,y0=0) {
			super();
			lastPos = new Point(x0,y0);
			pos = new Point(x0,y0);
			accel = new Point();
			vel = new Point();
			thickness = 1;
			color = 0xDDDDDD;
			radiusWhenStill = 1.5;
			dotRadius = 1;
			dotRadiusVariance = 1;
			
			attack = 100+Math.random()*10;
			hold = 60+Math.random()*30;
			decay = 70+Math.random()*100;
			rInit = 0;
			rHold = 1.5;
			rLast = 0.5;
			
			ribbonAlpha = 1;
			
			dead = false;
			angle = 0;
			_maxRotation = Math.PI*2/64;
			rotationInc = (2*Math.random()-1)*_maxRotation;
		}
		
		public function setEnvelope(a:Number, h:Number, d:Number, av:Number, hv:Number, dv:Number, r0:Number, r1:Number, r2:Number, rv:Number):void {
			attack = a+(2*Math.random()-1)*av;
			hold = h+(2*Math.random()-1)*hv;
			decay = d+(2*Math.random()-1)*dv;
			rInit = r0;
			rHold = r1;
			rLast = r2;
			dotRadiusVariance = rv;
			rad = rInit;
		}
		
		public function set maxRotation(a:Number):void {
			_maxRotation = a;
			rotationInc = (2*Math.random()-1)*_maxRotation;
		}
		
		public function resetPosition(x0=0,y0=0) {
			lastPos = new Point(x0,y0);
			pos = new Point(x0,y0);
		}
		
		public function redraw():void {
			lastRad = rad;
			this.graphics.clear();
			//dot:
			if (lifespan < attack+hold+decay) {
				if (lifespan < attack) {
					rad = (rHold - rInit)/attack*(lifespan) + rInit;
				}
				else if (lifespan < attack+hold) {
					rad = rHold;
				}
				else if (lifespan < attack+hold+decay) {
					rad = (rLast - rHold)/decay*(lifespan-attack-hold) + rHold;
				}
				rad = (1+dotRadiusVariance*(1-2*Math.random()))*rad;
				
				this.graphics.lineStyle(1,color,ribbonAlpha);
				cos = lastRad*Math.cos(angle);
				sin = lastRad*Math.sin(angle);
				v1x = lastPos.x-cos;
				v1y = lastPos.y+sin;
				this.graphics.beginFill(color,ribbonAlpha);
				this.graphics.moveTo(v1x,v1y);
				this.graphics.lineTo(lastPos.x+cos,lastPos.y-sin);
				
				angle += rotationInc;
				//angle=Math.random()*Math.PI;
				
				cos = rad*Math.cos(angle);
				sin = rad*Math.sin(angle);
				this.graphics.lineStyle(1,0xffffff,0.5);
				this.graphics.lineTo(pos.x+cos,pos.y-sin);
				this.graphics.lineStyle(1,color,ribbonAlpha);
				this.graphics.lineTo(pos.x-cos,pos.y+sin);
				this.graphics.lineStyle(1,0xffffff,0.5);
				this.graphics.lineTo(v1x,v1y);
				this.graphics.endFill();
			}
			else {
				dead = true;
			}
								
		}
		
	}
}
			
		