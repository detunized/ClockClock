@interface ClockView: UIView
{
	float _hourAngle;
	float _minuteAngle;

	float _hourAngleSpeed;
	float _minuteAngleSpeed;
	float _animationTime;
}

- (void)setAngles:(float)hourAngle minuteAngle:(float)minuteAngle;
- (bool)isAnimating;
- (void)animateTo:(float)hourAngle minuteAngle:(float)minuteAngle duration:(float)duration;
- (void)spin:(float)angle duration:(float)duration;
- (void)spinBothWays:(float)angle duration:(float)duration;
- (void)spinRandomly:(float)angle duration:(float)duration;
- (void)update:(float)dt;

@end
