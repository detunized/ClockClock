#import <map>
#import "Settings.h"

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

	NSDateComponents *components = [[NSCalendar currentCalendar] components:-1 fromDate:[NSDate date]];
	_hour = components.hour ;
	_minute = components.minute;
	
	for (int i = 0; i < Day_Count; ++i)
	{
		_repeat[i] = false;
	}
	
	_name = "Alarm";
	_sound = [GetSound(0) UTF8String];
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

NSDate *Alarm::getNextTimeGoOff() const
{
	NSCalendar *cal = [NSCalendar currentCalendar];
	NSDate *now = [NSDate date];

	NSDateComponents *nowSplit = [cal components:-1 fromDate:now];
	nowSplit.hour = _hour;
	nowSplit.minute = _minute;
	nowSplit.second = 0;
	
	NSDate *next = [cal dateFromComponents:nowSplit];
	while ([next timeIntervalSinceDate:now] < 0)
	{
		NSDateComponents *day = [NSDateComponents new];
		day.day = 1;
		next = [cal dateByAddingComponents:day toDate:next options:0];
		[day release];
	}
	
	NSDate *nextRepeat = next;
	int weekday = [nowSplit weekday];
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
