#import <map>
#import "Settings.h"

namespace
{
	typedef std::map<std::string, std::string> SoundMap;
	SoundMap _sounds;
};

Settings Settings::_settings;

int Alarm::GetSoundCount()
{
	CollectSounds(false);

	return _sounds.size();
}

std::string const &Alarm::GetSound(int index)
{
	CollectSounds(false);

	SoundMap::iterator i = _sounds.begin();
	std::advance(i, index);
	return i->first;
}

std::string const &Alarm::GetSoundFilename(int index)
{
	CollectSounds(false);

	SoundMap::iterator i = _sounds.begin();
	std::advance(i, index);
	return i->second;
}

void Alarm::CollectSounds(bool force)
{
	if (force || _sounds.size() == 0)
	{
		NSArray *filenames = [[NSBundle mainBundle] pathsForResourcesOfType:@"wav" inDirectory:@"alarms"];
		for (NSString *i in filenames)
		{
			_sounds[[[[i lastPathComponent] stringByDeletingPathExtension] UTF8String]] = [i UTF8String];
		}
	}
}
