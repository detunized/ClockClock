AVAudioPlayer *LoadSound(NSString *filename);

inline void PlaySound(NSString *filename)
{
	[LoadSound(filename) play];
}

void SplitTime(NSDate *time, int *hour, int *minute, int *second = 0, int *weekday = 0);
