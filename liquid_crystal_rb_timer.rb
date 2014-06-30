#To (re)compile C bytecode:
#
#/path/to/mruby/bin/mrbc -Bliquid_crystal_example -oliquid_crystal_example.c liquid_crystal_example.rb
#
# button-related implementation taken from http://arduino-info.wikispaces.com/LCD-Pushbuttons

class LiquidCrystalRbTimer
	include Arduino

  BTN_RIGHT  = 0
  BTN_UP     = 1
  BTN_DOWN   = 2
  BTN_LEFT   = 3
  BTN_SELECT = 4
  BTN_NONE   = 5
  WORK_MS = 25 * 60 * 1000
  REST_MS = 5 * 60 * 1000
  MODE_WORK = 'WORK'
  MODE_REST = 'REST'

	def initialize
    @lcd = LiquidCrystal.new(8, 9, 4, 5, 6, 7) # this depends on your specific liquid crystal shield
    @lcd.begin(16, 2)
    @remaining = WORK_MS
    @previous_now = 0
    @current_mode = MODE_WORK
    @paused = true
    @prev_lcd_key = BTN_NONE

    # This depends on your setup. I have work LED on pin 53, rest LED on pin 52
    @work_pin = 53
    @rest_pin = 52
    pinMode(@work_pin, OUTPUT)
    pinMode(@rest_pin, OUTPUT)
	end

	def run
    now = millis
    elapsed = now - @previous_now

    lcd_key = read_lcd_buttons

    @remaining -= elapsed unless @paused

    act_if_key_released(lcd_key)

    @prev_lcd_key = lcd_key

    print_remaining_time

    @previous_now = now
    @lcd.setCursor(0,1)

    show_current_mode
  end

  def act_if_key_released(current_key)
    # we perform an action upon release of the button
    if current_key == BTN_NONE
      case @prev_lcd_key
      when BTN_RIGHT
        next_mode
      when BTN_UP
        @paused = !(@paused)
      else
        next_if_done
      end
    end
  end

  def next_if_done
    if @remaining < 0
      next_mode
    end
  end

  def print_remaining_time
    @lcd.setCursor(0,0)
    @lcd.print(format_time(seconds_remaining))
  end

  def seconds_remaining
    (@remaining / 1000).to_i
  end

  def show_current_mode
    set_current_led
    print_current_mode
  end

  def set_current_led
    if @paused
      digitalWrite(@rest_pin, LOW)
      digitalWrite(@work_pin, LOW)
    else
      set_work_or_rest_led
    end
  end

  def set_work_or_rest_led
    if @current_mode == MODE_WORK
      digitalWrite(@rest_pin, LOW)
      digitalWrite(@work_pin, HIGH)
    else
      digitalWrite(@rest_pin, HIGH)
      digitalWrite(@work_pin, LOW)
    end
  end

  def print_current_mode
    @lcd.print(@current_mode)
    @lcd.print(' ')

    print_pause_status
  end

  def print_pause_status
    if @paused
      @lcd.print('(Paused) ')
    else
      @lcd.print('(Running)')
    end
  end

  def next_mode
    if @current_mode == MODE_WORK
      @remaining = REST_MS
      @current_mode = MODE_REST
    else
      @remaining = WORK_MS
      @current_mode = MODE_WORK
    end
  end

  def format_time(remaining)
    mins = (remaining / 60).to_i
    secs = remaining % 60

    # sprintf halts for some reason...
    zeropad_digits(mins) + ":" + zeropad_digits(secs)
  end

  # implementing what should be done with %02d
  def zeropad_digits(val)
    if val >= 10
      val.to_s
    else
      "0" + val.to_s
    end
  end

  def read_lcd_buttons
    adc_key_in = analogRead(0) # read the value from the sensor 

    delay(5) # switch debounce delay. Increase this delay if incorrect switch selections are returned.
    k = analogRead(0) - adc_key_in # gives the button a slight range to allow for a little contact resistance noise

    return BTN_NONE if 5 < k.abs # double checks the keypress. If the two readings are not equal +/-k value after debounce delay, it tries again.

    # this depends on your shield as well.
    # my values - R: 0, U 212-213, D: 489, L: 751-752, S: no response
    # it dosen't seem to do anything for select...
    case 
    when adc_key_in > 1000
      return BTN_NONE
    when adc_key_in < 50
      return BTN_RIGHT
    when adc_key_in < 265
      return BTN_UP
    when adc_key_in < 540
      return BTN_DOWN
    when adc_key_in < 800
      return BTN_LEFT 
    # when adc_key_in < ???
    #   return BTN_SELECT
    else
      return BTN_NONE;  # when all others fail, return this.
    end
  end
end
