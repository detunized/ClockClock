#import <map>
#import "Settings.h"
#import "Utils.h"

enum AlarmButton
{
	AlarmButton_TurnOff,
	AlarmButton_Snooze,
	
	AlarmButton_Count
};

static int const SnoozeTime = 15;//10 * 60; // snooze in 10 minutes

@interface AlarmListener: NSObject<UIAlertViewDelegate>
{
	UIAlertView *alert;
	Alarm *alarm;
	NSTimer *buzzTimer;
	NSTimer *snoozeTimer;
}

@property (nonatomic, retain) UIAlertView *alert;
@property (nonatomic, assign) Alarm *alarm;
@property (nonatomic, retain) NSTimer *buzzTimer;
@property (nonatomic, retain) NSTimer *snoozeTimer;

@end

@implementation AlarmListener

@synthesize alert;
@synthesize alarm;
@synthesize buzzTimer;
@synthesize snoozeTimer;

- (void)reset
{
	self.alert = nil;
	self.alarm = 0;

	[self.buzzTimer invalidate];
	self.buzzTimer = nil;
	
	[self.snoozeTimer invalidate];
	self.snoozeTimer = nil;
}

- (void)timerCallback:(NSTimer*)timer
{
	[[NSNotificationCenter defaultCenter] postNotificationName:@"alarm" object:timer.userInfo];
	
	if (timer.userInfo)
	{
		self.alarm = (Alarm *)[timer.userInfo unsignedIntValue];
		if (!self.alarm->isRepeating())
		{
			self.alarm->setEnabled(false);
		}

		self.alarm->setGoingOff(true);
	}
	else
	{
		assert(self.alarm);
		assert(self.alarm->isGoingOff());
		assert(self.alarm->isSnoozing());
	}

	self.alert = [[[UIAlertView alloc] initWithTitle:@"Alarm" 
											message:@"What?" 
										   delegate:self 
								  cancelButtonTitle:@"Turn off" 
								  otherButtonTitles:@"Snooze", nil] autorelease];
	
	PlaySound(self.alarm->getSoundFilename());
	self.buzzTimer = [NSTimer scheduledTimerWithTimeInterval:3 target:self selector:@selector(playSound:) userInfo:nil repeats:YES];
	
	[self.alert show];
}

- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex
{
	[self.buzzTimer invalidate];
	self.buzzTimer = nil;
	
	[self.snoozeTimer invalidate];
	self.snoozeTimer = nil;
	
	switch (buttonIndex)
	{
		case AlarmButton_TurnOff:
		{
			self.alarm->setGoingOff(false);
			self.alarm->setSnoozing(false);
	
			if (self.alarm->getEnabled())
			{
				// set alarm for next repeat cycle
				assert(self.alarm->isRepeating());
				self.alarm->setTimer();
			}
			
			self.alarm = 0;

			break;
		}
		case AlarmButton_Snooze:
		{
			self.alarm->setSnoozing(true); 
			
			[self.snoozeTimer invalidate];
			self.snoozeTimer = [NSTimer scheduledTimerWithTimeInterval:SnoozeTime target:self selector:@selector(timerCallback:) userInfo:nil repeats:NO];

			break;
		}
	}
	
	// release
	self.alert = nil;
}

- (void)playSound:(NSTimer*)timer
{
	PlaySound(self.alarm->getSoundFilename());
}

@end

namespace
{
	typedef std::map<std::string, NSString *> SoundMap;
	SoundMap _sounds;
	
	static const NSString *_shortDays[Alarm::Day_Count] =
	{
		@"Sun",
		@"Mon",
		@"Tue",
		@"Wed",
		@"Thu",
		@"Fri",
		@"Sat",
	};

	AlarmListener *_alarmListener = [AlarmListener new];
};

Settings Settings::_settings;

int Alarm::GetSoundCount()
{
	CollectSounds(false);

	return _sounds.size();
}

NSString *Alarm::GetSound(int index)
{
	CollectSounds(false);

	SoundMap::iterator i = _sounds.begin();
	std::advance(i, index);
	return [NSString stringWithUTF8String:i->first.c_str()];
}

NSString *Alarm::GetSoundFilename(int index)
{
	CollectSounds(false);

	SoundMap::iterator i = _sounds.begin();
	std::advance(i, index);
	return i->second;
}

Alarm::Alarm()
{
	_enabled = true;
	SplitTime([NSDate date], &_hour, &_minute);
	_name = "Alarm";
	_sound = [GetSound(0) UTF8String];
	
	for (int i = 0; i < Day_Count; ++i)
	{
		_repeat[i] = false;
	}
	
	_listener = 0;
	_timer = 0;
}

NSString *Alarm::getTimeString() const
{
	return [NSString stringWithFormat:@"%02d:%02d", _hour, _minute];
}

NSString *Alarm::getRepeatString() const
{
	NSMutableString *result = [NSMutableString stringWithCapacity:_shortDays[0].length * 7 + 6];
 	for (int i = 0; i < Day_Count; ++i)
	{
		if (_repeat[i])
		{
			if (result.length != 0)
			{
				[result appendString:@" "];
			}
			
			[result appendString:_shortDays[i]];
		}
	}
	
	return result.length == 0 ? @"Never" : result;
}

NSString *Alarm::getSoundString() const
{
	return _sound == "" ? @"None" : [NSString stringWithUTF8String:_sound.c_str()];
}

NSString *Alarm::getNameString() const
{
	return _name == "" ? @"No name" : getName();
}

NSString *Alarm::getSoundFilename() const
{
	CollectSounds(false);
	
	return _sound == "" ? 0 : _sounds[_sound];
}

NSDate *Alarm::getNextTimeGoOff() const
{
	NSCalendar *cal = [NSCalendar currentCalendar];
	NSDate *now = [NSDate date];

	NSDateComponents *nowSplit = [cal components:-1 fromDate:now];
	nowSplit.hour = _hour;
	nowSplit.minute = _minute;
	nowSplit.second = 0;
	int weekday = [nowSplit weekday] - 1;
	
	NSDate *next = [cal dateFromComponents:nowSplit];
	while ([next timeIntervalSinceDate:now] < 0)
	{
		NSDateComponents *day = [NSDateComponents new];
		day.day = 1;
		next = [cal dateByAddingComponents:day toDate:next options:0];
		[day release];
		weekday = (weekday + 1) % Day_Count;
	}
	
	NSDate *nextRepeat = next;
	for (int i = 0; i < Day_Count; ++i)
	{
		if (_repeat[(weekday + i) % Day_Count])
		{
			return nextRepeat;
		}
		
		NSDateComponents *day = [NSDateComponents new];
		day.day = 1;
		nextRepeat = [cal dateByAddingComponents:day toDate:nextRepeat options:0];
		[day release];
	}

	return next;
}

void Alarm::CollectSounds(bool force)
{
	if (force || _sounds.size() == 0)
	{
		NSArray *filenames = [[NSBundle mainBundle] pathsForResourcesOfType:@"wav" inDirectory:@"alarms"];
		for (NSString *i in filenames)
		{
			_sounds[[[[i lastPathComponent] stringByDeletingPathExtension] UTF8String]] = [i copy];
		}
	}
}

Alarm::Alarm(NSDictionary *archive)
{
	_enabled = [[archive objectForKey:@"enabled"] boolValue];
	_hour = [[archive objectForKey:@"hour"] intValue];
	_minute = [[archive objectForKey:@"minute"] intValue];
	_name = [[archive objectForKey:@"name"] UTF8String];
	_sound = [[archive objectForKey:@"sound"] UTF8String];
	
	NSArray *repeat = [archive objectForKey:@"repeat"];
	for (int i = 0; i < Day_Count; ++i)
	{
		_repeat[i] = [[repeat objectAtIndex:i] boolValue];
	}
	
	_timer = 0;
}

NSDictionary *Alarm::serialize() const
{
	return [NSDictionary dictionaryWithObjectsAndKeys:
			[NSNumber numberWithBool:_enabled], @"enabled", 
			[NSNumber numberWithInt:_hour], @"hour", 
			[NSNumber numberWithInt:_minute], @"minute", 
			[NSArray arrayWithObjects:
			 [NSNumber numberWithBool:_repeat[Day_Sunday]],
			 [NSNumber numberWithBool:_repeat[Day_Monday]],
			 [NSNumber numberWithBool:_repeat[Day_Tuesday]],
			 [NSNumber numberWithBool:_repeat[Day_Wednesday]],
			 [NSNumber numberWithBool:_repeat[Day_Thursday]],
			 [NSNumber numberWithBool:_repeat[Day_Friday]],
			 [NSNumber numberWithBool:_repeat[Day_Saturday]],
			 nil
			 ], @"repeat", 
			getName(), @"name",
			getSound(), @"sound",
			nil];
}

void Alarm::setTimer()
{
	removeTimer();

	if (_enabled)
	{
		_timer = [[NSTimer alloc] initWithFireDate:getNextTimeGoOff() 
										  interval:0 
											target:_alarmListener 
										  selector:@selector(timerCallback:)
										  userInfo:[NSNumber numberWithUnsignedInt:(unsigned int)this]
										   repeats:NO];
		[[NSRunLoop currentRunLoop] addTimer:_timer forMode:NSDefaultRunLoopMode];
		
		NSLog(@"Timer set on %@", _timer.fireDate);
	}
}

void Alarm::removeTimer()
{
	[_timer release];
	_timer = 0;
}

void Settings::load()
{
	if (!_loaded)
	{
		// these are default values in case they are not in the db
		NSDictionary *defaults = [NSDictionary dictionaryWithObjectsAndKeys:
								  [NSArray arrayWithObjects:nil], @"alarms",
								  [NSNumber numberWithBool:_playTickSound], @"play_tick_sound",
								  nil];
		
		NSUserDefaults *ud = [NSUserDefaults standardUserDefaults];
		[ud registerDefaults:defaults];
		
		NSArray *alarms = [ud arrayForKey:@"alarms"];
		for (NSDictionary *i in alarms)
		{
			_alarms.push_back(Alarm(i));
			_alarms.back().setTimer();
		}
		
		_playTickSound = [ud boolForKey:@"play_tick_sound"];
		
		_loaded = true;
	}
}

void Settings::save()
{
	NSMutableArray *alarms = [NSMutableArray arrayWithCapacity:getAlarmCount()];
	for (int i = 0, count = getAlarmCount(); i < count; ++i)
	{
		[alarms addObject:_alarms[i].serialize()];
	}
	
	NSUserDefaults *ud = [NSUserDefaults standardUserDefaults];
	[ud setObject:alarms forKey:@"alarms"];
	[ud setBool:_playTickSound forKey:@"play_tick_sound"];
	[ud synchronize];
}
