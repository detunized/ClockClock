#import "ClockView.h"

@implementation ClockView

- (id)initWithFrame:(CGRect)frame
{
    if (self = [super initWithFrame:frame])
	{
		self.opaque = NO;
		
		_hourAngle = 0;
		_minuteAngle = 0;

		_hourAngleSpeed = 0;
		_minuteAngleSpeed = 0;
		_animationTime = 0;
    }
   
	return self;
}

- (void)dealloc
{
    [super dealloc];
}

- (void)drawHand:(CGContextRef)context at:(CGPoint)at length:(float)length angle:(float)angle
{
	float x = cosf(angle) * length;
	float y = sinf(angle) * length;
	CGContextMoveToPoint(context, at.x, at.y);
	CGContextAddLineToPoint(context, at.x + x, at.y - y);
}

- (void)drawClock:(CGContextRef)context at:(CGPoint)at hourAngle:(float)hourAngle minuteAngle:(float)minuteAngle
{
	float const w = 5;
	
	CGContextSetRGBStrokeColor(context, 1, 1, 1, 1);
	CGContextSetLineWidth(context, w);
	
	[self drawHand:context at:at length:19 angle:hourAngle];
	[self drawHand:context at:at length:21 angle:minuteAngle];
	
	CGContextStrokePath(context);
}

- (void)drawRect:(CGRect)rect
{
	[self drawClock:UIGraphicsGetCurrentContext() 
				 at:CGPointMake(self.frame.size.width / 2, self.frame.size.height / 2) 
		  hourAngle:_hourAngle
		minuteAngle:_minuteAngle];
}

- (void)setAngles:(float)hourAngle minuteAngle:(float)minuteAngle
{
	_hourAngle = hourAngle;
	_minuteAngle = minuteAngle;
	[self setNeedsDisplay];
}

- (bool)isAnimating
{
	return _animationTime > 0;
}

- (void)animateTo:(float)hourAngle minuteAngle:(float)minuteAngle duration:(float)duration
{
	_animationTime = duration;
	_hourAngleSpeed = (hourAngle - _hourAngle) / duration;
	_minuteAngleSpeed = (minuteAngle - _minuteAngle) / duration;
}

- (void)spin:(float)angle duration:(float)duration
{
	[self animateTo:(_hourAngle + angle) minuteAngle:(_minuteAngle + angle) duration:duration];
}

- (void)spinBothWays:(float)angle duration:(float)duration
{
	[self animateTo:(_hourAngle + angle) minuteAngle:(_minuteAngle - angle) duration:duration];
}

- (void)spinRandomly:(float)angle duration:(float)duration
{
	if (rand() < RAND_MAX / 2)
	{
		angle = -angle;
	}

	if (rand() < RAND_MAX / 2)
	{
		[self spin:angle duration:duration];
	}
	else
	{
		[self spinBothWays:angle duration:duration];
	}
}

- (void)update:(float)dt
{
	if (_animationTime > 0)
	{
		if (dt > _animationTime)
		{
			dt = _animationTime;
		}
		
		_hourAngle += _hourAngleSpeed * dt;
		_minuteAngle += _minuteAngleSpeed * dt;

		_animationTime -= dt;
		
		if (_animationTime <= 0.0001f)
		{
			_hourAngle = fmodf(_hourAngle + M_PI * 200, M_PI * 2);
			_minuteAngle = fmodf(_minuteAngle + M_PI * 200, M_PI * 2);
		}
		
		[self setNeedsDisplay];
	}
}

@end
