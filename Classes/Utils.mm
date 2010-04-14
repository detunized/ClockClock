#import "Utils.h"

static NSMutableDictionary *_sounds = [NSMutableDictionary new];

AVAudioPlayer *LoadSound(NSString *filename)
{
	AVAudioPlayer *player = [_sounds objectForKey:filename];
	
	if (!player)
	{
		player = [[AVAudioPlayer alloc] autorelease];
		[_sounds setObject:player forKey:filename];
		
		NSURL *url = [NSURL fileURLWithPath:filename];
		NSError *error;
		[player initWithContentsOfURL:url error:&error];
	}
	
	[player prepareToPlay];
	return player;
}

void SplitTime(NSDate *time, int *hour, int *minute, int *second, int *weekday)
{
	NSCalendar *calendar = [NSCalendar currentCalendar];
	NSDateComponents *components = [calendar 
									components:(NSHourCalendarUnit | NSMinuteCalendarUnit | NSSecondCalendarUnit | NSWeekdayCalendarUnit) 
									fromDate:time];
	if (hour)
	{
		*hour = components.hour;
	}
	
	if (minute)
	{
		*minute = components.minute;
	}
	
	if (second)
	{
		*second = components.second;
	}
	
	if (weekday)
	{
		*weekday = components.weekday - 1;
	}
}

