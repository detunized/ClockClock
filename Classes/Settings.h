#pragma once

#include <vector>
#include <string>

class Alarm
{
public:
	enum Day
	{
		Day_Monday,
		Day_Tuesday,
		Day_Wednesday,
		Day_Thursday,
		Day_Friday,
		Day_Saturday,
		Day_Sunday,
		
		Day_Count
	};
	
	static int GetSoundCount();
	static NSString *GetSound(int index);
	static NSString *GetSoundFilename(int index);
	
	Alarm()
	{
		_enabled = true;
		_hour = 0;
		_minute = 0;
		
		for (int i = 0; i < Day_Count; ++i)
		{
			_repeat[i] = false;
		}
	}
	
	Alarm(NSDictionary *archive);
	
	bool getEnabled() const
	{
		return _enabled;
	}
	
	void setEnabled(bool enabled)
	{
		_enabled = enabled;
	}

	int getHour() const
	{
		return _hour;
	}
	
	void setHour(int hour)
	{
		_hour = hour;
	}
	
	int getMinute() const
	{
		return _minute;
	}
	
	void setMinute(int minute)
	{
		_minute = minute;
	}
	
	bool getRepeat(Day day)
	{
		return _repeat[day];
	}

	void setRepeat(Day day, bool repeat)
	{
		_repeat[day] = repeat;
	}
	
	NSString *getName() const
	{
		return [NSString stringWithUTF8String:_name.c_str()];
	}

	void setName(NSString *name)
	{
		_name = [name UTF8String];
	}

	NSString *getSound() const
	{
		return [NSString stringWithUTF8String:_sound.c_str()];
	}
	
	void setSound(NSString *sound)
	{
		_sound = [sound UTF8String];
	}

	NSString *getTimeString() const;
	NSString *getRepeatString() const;
	NSString *getSoundString() const;
	NSString *getNameString() const;
	
	NSDictionary *serialize() const;

private:
	static void CollectSounds(bool force);
	
	bool _enabled;
	int _hour;
	int _minute;
	bool _repeat[Day_Count];
	std::string _name;
	std::string _sound;
};

class Settings
{
public:
	static Settings &Get()
	{
		_settings.load();
		return _settings;
	}
	
	Settings()
	{
		_loaded = false;
		resetToDefaults();
	}
	
	void resetToDefaults()
	{
		_alarms.clear();
		_playTickSound = true;
	}
	
	int getAlarmCount() const
	{
		return _alarms.size();
	}
	
	Alarm const &getAlarm(int index) const
	{
		return _alarms[index];
	}
	
	void setAlarm(int index, Alarm const &alarm)
	{
		_alarms[index] = alarm;
		save();
	}
	
	void addAlarm(Alarm const &alarm)
	{
		_alarms.push_back(alarm);
		save();
	}

	void removeAlarm(int index)
	{
		_alarms.erase(_alarms.begin() + index);
		save();
	}
	
	bool getPlayTickSound() const
	{
		return _playTickSound;
	}
	
	void setPlayTickSound(bool playTickSound)
	{
		_playTickSound = playTickSound;
		save();
	}
	
private:
	void load();
	void save();

	static Settings _settings;
	
	bool _loaded;
	std::vector<Alarm> _alarms;
	bool _playTickSound;
};
