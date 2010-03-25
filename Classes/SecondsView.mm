#import "SecondsView.h"

@implementation SecondsView

- (void)awakeFromNib
{
	self.opaque = NO;
	_angle = 0;
}

- (void)drawRect:(CGRect)rect
{
	float const w = 2;
	
	CGContextRef context = UIGraphicsGetCurrentContext();
	CGContextSetRGBStrokeColor(context, 1, 1, 1, 1);
	CGContextSetLineWidth(context, w);
	
	// frame
	CGContextAddEllipseInRect(context, CGRectMake(w, w, self.bounds.size.width - w * 2, self.bounds.size.height - w * 2));

	// hand
	float x = self.bounds.size.width / 2;
	float y = self.bounds.size.height / 2;
	float r = self.bounds.size.width / 2 - w * 3;
	float dx = cosf(_angle) * r;
	float dy = sinf(_angle) * r;

	CGContextMoveToPoint(context, x, y);
	CGContextAddLineToPoint(context, x + dx, y - dy);

	CGContextStrokePath(context);
}

- (void)dealloc
{
    [super dealloc];
}

- (void)setSeconds:(int)seconds
{
	_angle = M_PI * 2 * (0.25f - seconds % 60 / 60.0f);
	[self setNeedsDisplay];
}

@end
