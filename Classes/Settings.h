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
	static std::string const &GetSound(int index);
	static std::string const &GetSoundFilename(int index);
	
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
	
	std::string const &getName() const
	{
		return _name;
	}
	
	void setName(std::string const &name)
	{
		_name = name;
	}

	std::string const &getSound() const
	{
		return _sound;
	}
	
	void setSound(std::string const &sound)
	{
		_sound = sound;
	}

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
		return _settings;
	}
	
	Settings()
	{
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
	}
	
	void addAlarm(Alarm const &alarm)
	{
		_alarms.push_back(alarm);
	}

	void removeAlarm(int index)
	{
		_alarms.erase(_alarms.begin() + index);
	}
	
	bool getPlayTickSound() const
	{
		return _playTickSound;
	}
	
	void setPlayTickSound(bool playTickSound)
	{
		_playTickSound = playTickSound;
	}
	
private:
	static Settings _settings;
	
	std::vector<Alarm> _alarms;
	bool _playTickSound;
};
