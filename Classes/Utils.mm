#import <AVFoundation/AVFoundation.h>
#import "Utils.h"

void PlaySound(NSString *filename)
{
	AVAudioPlayer *player = [AVAudioPlayer alloc];
	NSURL *url = [NSURL fileURLWithPath:filename];
	NSError *error;
	[player initWithContentsOfURL:url error:&error];
	[player play];
}
