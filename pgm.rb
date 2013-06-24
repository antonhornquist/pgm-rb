require 'set'

module PGM
	HEADER_SIZE = 24
	SAMPLE_DATA_SIZE = 24
	PAD_DATA_SIZE = 164
	SLIDER_DATA_SIZE = 0x0D
	NUM_SAMPLES_PER_PAD = 4
	NUM_PADS = 64
	NUM_MIDI_NOTES = 128
	NUM_SLIDERS = 2
	
	MIDI_SECTION_OFFSET = HEADER_SIZE + NUM_PADS * PAD_DATA_SIZE
	SLIDERS_SECTION_OFFSET = 0x29D9
	VALID_FILE_SIZE_IN_BYTES = 0x2A04

	MIDI_SECTION_SIZE = SLIDERS_SECTION_OFFSET - MIDI_SECTION_OFFSET

	VALID_FILETYPE_STRING = "MPC1000 PGM 1.00"
	
	module Defaults
		PROGRAM_PLAY = :poly

		SAMPLE = {
			:sample_name => "",
			:level => 100,
			:range_lower => 0,
			:range_upper => 127,
			:tuning => 0,
			:play_mode => :one_shot,
			:velocity_to_pitch => 0,
		}

		PAD = {
			:voice_overlap=>:poly,
      :mute_group=>:off,
      :attack=>0,
      :decay=>5,
      :decay_mode=>:end,
      :velocity_to_attack=>0,
      :velocity_to_start=>0,
      :velocity_to_level=>100,
      :filter1_type=>:off,
      :filter1_freq=>100,
      :filter1_res=>0,
			:filter1_envelope_time=>0,
			:filter1_envelope_amount=>0,
			:filter1_velocity_to_time=>0,
			:filter1_velocity_to_amount=>0,
      :filter1_velocity_to_frequency=>0,
      :filter2_type=>:off,
      :filter2_freq=>100,
      :filter2_res=>0,
			:filter2_envelope_time=>0,
			:filter2_envelope_amount=>0,
			:filter2_velocity_to_time=>0,
			:filter2_velocity_to_amount=>0,
      :filter2_velocity_to_frequency=>0,
			:lfo_rate=>0,
			:lfo_delay=>0,
			:lfo_wave=>:triangle,
			:lfo_pitch=>0,
			:lfo_filter1=>0,
			:lfo_filter2=>0,
			:lfo_level=>0,
      :mixer_level=>100,
      :mixer_pan=>50,
      :output=>:stereo,
      :fx_send=>:off,
      :fx_send_level=>0,
      :filter_attenuation=>:zerodb,
      :mute_target1=>:off,
      :mute_target2=>:off,
      :mute_target3=>:off,
      :mute_target4=>:off
		}

		SLIDER = {
			:pad=>:off,
	    :change=>:note_on,
	    :parameter=>:tune,
	    :tune_low=>-120,
	    :tune_high=>120,
	    :filter_low=>-50,
	    :filter_high=>50,
	    :layer_low=>0,
	    :layer_high=>127,
	    :attack_low=>0,
	    :attack_high=>100,
	    :decay_low=>0,
	    :decay_high=>100
		}

		SLIDER_EXTRA = {
	    :slider_level_low=>0,
	    :slider_level_high=>100
		}

		MIDI = {
			:pad_midi_note_values => Array.new(NUM_PADS) { |i| i },
			:midi_note_pad_values => Array.new(NUM_MIDI_NOTES) { :unassigned },
			:midi_program_change => :off
		}

		PROGRAM = {
			:program_play => Defaults::PROGRAM_PLAY,
			:pads => Array.new(NUM_PADS) do
				{
					:pad => Defaults::PAD,
					:samples => Array.new(NUM_SAMPLES_PER_PAD) { Defaults::SAMPLE }
				}
			end,
			:midi => Defaults::MIDI,
			:sliders => Array.new(NUM_SLIDERS) { Defaults::SLIDER },
			:sliders_extra => Array.new(NUM_SLIDERS) { Defaults::SLIDER_EXTRA }
		}
	end

	class <<self
		def read_file(fname)
			unpack_pgm(IO.read(fname, :mode => "rb"))
		end

		def write_file(fname, pgm)
			raise "File #{fname} already exists" if File.exists?(fname)
			str = pack_pgm(pgm)
			IO.write(fname, str, :mode => "wb")
		end

		def unpack_pgm(str)
			header = unpack_header(str)
			raise "Not a valid program file" unless valid_pgm_file?(str, header)
		
			{
				:program_play => header[:program_play],
				:pads => Array.new(NUM_PADS) do |p|
					offset = HEADER_SIZE + p * PAD_DATA_SIZE
					pad_offset = offset + SAMPLE_DATA_SIZE * NUM_SAMPLES_PER_PAD
					{
						:pad => unpack_pad(str[pad_offset...pad_offset + PAD_DATA_SIZE]),
						:samples => Array.new(NUM_SAMPLES_PER_PAD) do |s|
							sample_offset = offset + SAMPLE_DATA_SIZE * s
							unpack_sample(str[sample_offset...sample_offset + SAMPLE_DATA_SIZE])
						end
					}
				end,
				:midi => unpack_midi(str[MIDI_SECTION_OFFSET...SLIDERS_SECTION_OFFSET]),
				:sliders => Array.new(NUM_SLIDERS) do |r|
					offset = SLIDERS_SECTION_OFFSET + r * SLIDER_DATA_SIZE
					unpack_slider(str[offset...offset+SLIDER_DATA_SIZE])
				end,
				:sliders_extra => Array.new(NUM_SLIDERS) do |r|
					offset = SLIDERS_SECTION_OFFSET + 2 * SLIDER_DATA_SIZE + r * 2
					unpack_slider_extra(str[offset...offset+2])
				end
			}
		end
		
		def valid_pgm_file?(str, header)
			str.size == header[:file_size_in_bytes] and header[:file_size_in_bytes] == VALID_FILE_SIZE_IN_BYTES and header[:filetype_string] == VALID_FILETYPE_STRING
		end
		
		def pack_pgm(pgm)
			[
				pack_header(pgm[:program_play]),
				pgm[:pads].map do |pad|
					pad[:samples].map { |sample| pack_sample(sample) }.join + pack_pad(pad[:pad])
				end.join,
				pack_midi(pgm[:midi]),
				pgm[:sliders].map { |slider| pack_slider(slider) }.join,
				pgm[:sliders_extra].map { |slider_extra| pack_slider_extra(slider_extra) }.join,
				pack_footer
			].join
		end
		
		def unpack_header(str)
			arr = str.unpack("vx2A16xcx2")
			{
				:file_size_in_bytes => arr[0],
				:filetype_string => arr[1],
				:program_play => decode_program_play(arr[2])
			}
		end
		
		def pack_header(program_play)
			[
				VALID_FILE_SIZE_IN_BYTES,
				VALID_FILETYPE_STRING,
				encode_program_play(program_play)
			].pack("vx2A16xcx2")
		end
		
		def pack_footer
			[].pack("x13")
		end
		
		def unpack_sample(str)
			arr = str.unpack("Z16xC3vcC")
			range_lower = arr[2]
			range_upper = arr[3]
			{
				:sample_name => verified_string(:sample_name, arr[0], 16),
				:level => verified_param_value(:level, arr[1], 0, 100),
				:range_lower => verified_param_value(:range_lower, range_lower, 0, range_upper),
				:range_upper => verified_param_value(:range_upper, range_upper, range_lower, 127),
				:tuning => verified_param_value(:tuning, arr[4], -3600, 3600),
				:play_mode => decode_play_mode(arr[5]),
				:velocity_to_pitch => decode_velocity_to_pitch(arr[6])
			}
		end
		
		def pack_sample(sample)
			validate_keys("sample", sample, Defaults::SAMPLE)
			range_lower = sample[:range_lower]
			range_upper = sample[:range_upper]
			[
				verified_string(:sample_name, sample[:sample_name], 16),
				verified_param_value(:level, sample[:level], 0, 100),
				verified_param_value(:range_lower, range_lower, 0, range_upper),
				verified_param_value(:range_upper, range_upper, range_lower, 127),
				verified_param_value(:tuning, sample[:tuning], -3600, 3600),
				encode_play_mode(sample[:play_mode]),
				encode_velocity_to_pitch(sample[:velocity_to_pitch])
			].pack("Z16xC3vcC")
		end
		
		def validate_keys(name, input, default)
			input_keys = input.keys.to_set
			default_keys = default.keys.to_set
			raise "bad #{name} hash. expected keys: #{default_keys.to_a.map{|k|":#{k}"}.join(", ")}. got keys: #{input_keys.to_a.map{|k|":#{k}"}.join(", ")}." unless input_keys.intersection(default_keys).size == input_keys.size
		end

		def unpack_pad(str)
			arr = str.unpack("x2c2x2C2cC2Cx5cC2Cc3CcC2Cc3Cxv2C5x4C2c2Ccx2c4x9")
			{
				:voice_overlap => decode_voice_overlap(arr[0]),
				:mute_group => decode_mute_group(arr[1]),
				:attack => verified_param_value(:attack, arr[2], 0, 100),
				:decay => verified_param_value(:decay, arr[3], 0, 100),
				:decay_mode => decode_decay_mode(arr[4]),
				:velocity_to_attack => verified_param_value(:velocity_to_attack, arr[5], 0, 100),
				:velocity_to_start => verified_param_value(:velocity_to_start, arr[6], 0, 100),
				:velocity_to_level => verified_param_value(:velocity_to_level, arr[7], 0, 100),
				:filter1_type => decode_pad_filter1_type(arr[8]),
				:filter1_freq => verified_param_value(:filter1_freq, arr[9], 0, 100),
				:filter1_res => verified_param_value(:filter1_res, arr[10], 0, 100),
				:filter1_envelope_time => verified_param_value(:filter1_envelope_time, arr[11], 0, 100),
				:filter1_envelope_amount => verified_param_value(:filter1_envelope_amount, arr[12], -50, 50),
				:filter1_velocity_to_time => verified_param_value(:filter1_velocity_to_time, arr[13], -50, 50),
				:filter1_velocity_to_amount => verified_param_value(:filter1_velocity_to_amount, arr[14], -50, 50),
				:filter1_velocity_to_frequency => verified_param_value(:filter1_velocity_to_frequency, arr[15], 0, 100),
				:filter2_type => decode_pad_filter2_type(arr[16]),
				:filter2_freq => verified_param_value(:filter2_freq, arr[17], 0, 100),
				:filter2_res => verified_param_value(:filter2_res, arr[18], 0, 100),

				:filter2_envelope_time => verified_param_value(:filter2_envelope_time, arr[19], 0, 100),
				:filter2_envelope_amount => verified_param_value(:filter2_envelope_amount, arr[20], -50, 50),
				:filter2_velocity_to_time => verified_param_value(:filter2_velocity_to_time, arr[21], -50, 50),
				:filter2_velocity_to_amount => verified_param_value(:filter2_velocity_to_amount, arr[22], -50, 50),

				:filter2_velocity_to_frequency => verified_param_value(:filter2_velocity_to_frequency, arr[23], 0, 100),

				:lfo_rate => arr[24],
				:lfo_delay => arr[25],
				:lfo_wave => decode_lfo_wave(arr[26]),
				:lfo_pitch => verified_param_value(:lfo_pitch, arr[27], 0, 100),
				:lfo_filter1 => verified_param_value(:lfo_filter1, arr[28], 0, 100),
				:lfo_filter2 => verified_param_value(:lfo_filter2, arr[29], 0, 100),
				:lfo_level => verified_param_value(:lfo_level, arr[30], 0, 100),

				:mixer_level => verified_param_value(:mixer_level, arr[31], 0, 100),
				:mixer_pan => verified_param_value(:mixer_pan, arr[32], 0, 100),
				:output => decode_pad_output(arr[33]),
				:fx_send => decode_pad_fx_send(arr[34]),
				:fx_send_level => verified_param_value(:fx_send_level, arr[35], 0, 100),
				:filter_attenuation => decode_pad_filter_attenuation(arr[36]),
				:mute_target1 => decode_mute_target(arr[37]),
				:mute_target2 => decode_mute_target(arr[38]),
				:mute_target3 => decode_mute_target(arr[39]),
				:mute_target4 => decode_mute_target(arr[40]),
			}
		end
		
		def pack_pad(pad)
			validate_keys("pad", pad, Defaults::PAD)
			[
				encode_voice_overlap(pad[:voice_overlap]),
				encode_mute_group(pad[:mute_group]),
				0x01,
				verified_param_value(:attack, pad[:attack], 0, 100),
				verified_param_value(:decay, pad[:decay], 0, 100),
				encode_decay_mode(pad[:decay_mode]),
				verified_param_value(:velocity_to_attack, pad[:velocity_to_attack], 0, 100),
				verified_param_value(:velocity_to_start, pad[:velocity_to_start], 0, 100),
				verified_param_value(:velocity_to_level, pad[:velocity_to_level], 0, 100),
				encode_pad_filter1_type(pad[:filter1_type]),
				verified_param_value(:filter1_freq, pad[:filter1_freq], 0, 100),
				verified_param_value(:filter1_res, pad[:filter1_res], 0, 100),
				verified_param_value(:filter1_envelope_time, pad[:filter1_envelope_time], 0, 100),
				verified_param_value(:filter1_envelope_amount, pad[:filter1_envelope_amount], -50, 50),
				verified_param_value(:filter1_velocity_to_time, pad[:filter1_velocity_to_time], -50, 50),
				verified_param_value(:filter1_velocity_to_amount, pad[:filter1_velocity_to_amount], -50, 50),
				verified_param_value(:filter1_velocity_to_frequency, pad[:filter1_velocity_to_frequency], 0, 100),
				encode_pad_filter2_type(pad[:filter2_type]),
				verified_param_value(:filter2_freq, pad[:filter2_freq], 0, 100),
				verified_param_value(:filter2_res, pad[:filter2_res], 0, 100),
				verified_param_value(:filter2_envelope_time, pad[:filter2_envelope_time], 0, 100),
				verified_param_value(:filter2_envelope_amount, pad[:filter2_envelope_amount], -50, 50),
				verified_param_value(:filter2_velocity_to_time, pad[:filter2_velocity_to_time], -50, 50),
				verified_param_value(:filter2_velocity_to_amount, pad[:filter2_velocity_to_amount], -50, 50),
				verified_param_value(:filter2_velocity_to_frequency, pad[:filter2_velocity_to_frequency], 0, 100),
				pad[:lfo_rate],
				pad[:lfo_delay],
				encode_lfo_wave(pad[:lfo_wave]),
				verified_param_value(:lfo_pitch, pad[:lfo_pitch], 0, 100),
				verified_param_value(:lfo_filter1, pad[:lfo_filter1], 0, 100),
				verified_param_value(:lfo_filter2, pad[:lfo_filter2], 0, 100),
				verified_param_value(:lfo_level, pad[:lfo_level], 0, 100),
				verified_param_value(:mixer_level, pad[:mixer_level], 0, 100),
				verified_param_value(:mixer_pan, pad[:mixer_pan], 0, 100),
				encode_pad_output(pad[:output]),
				encode_pad_fx_send(pad[:fx_send]),
				verified_param_value(:fx_send_level, pad[:fx_send_level], 0, 100),
				encode_pad_filter_attenuation(pad[:filter_attenuation]),
				encode_mute_target(pad[:mute_target1]),
				encode_mute_target(pad[:mute_target2]),
				encode_mute_target(pad[:mute_target3]),
				encode_mute_target(pad[:mute_target4]),
			].pack("x2c2xcC2cC2Cx5cC2Cc3CcC2Cc3Cxv2C5x4C2c2Ccx2c4x9")
		end
		
		def unpack_midi(str)
			arr = str.unpack("C#{NUM_PADS}C#{NUM_MIDI_NOTES}C")
			{
				:pad_midi_note_values => arr[0...NUM_PADS].map { |c| verified_param_value(:pad_midi_notes_value, c, 0, 127) },
				:midi_note_pad_values => arr[NUM_PADS...NUM_PADS+NUM_MIDI_NOTES].map { |c| decode_midi_note_pad_value(c) },
				:midi_program_change => decode_midi_program_change(arr[NUM_PADS+NUM_MIDI_NOTES])
			}
		end
		
		def pack_midi(midi)
			validate_keys("midi", midi, Defaults::MIDI)
			[
				midi[:pad_midi_note_values].map { |pad_midi_note_value| verified_param_value(:pad_midi_notes_value, pad_midi_note_value, 0, 127) },
				midi[:midi_note_pad_values].map { |midi_note_pad_value| encode_midi_note_pad_value(midi_note_pad_value) },
				encode_midi_program_change(midi[:midi_program_change]),
			].flatten.pack("C#{NUM_PADS}C#{NUM_MIDI_NOTES}C")
		end
		
		def unpack_slider(str)
			arr = str.unpack("Cc12")
			slider_change_decoded = decode_slider_change(arr[1])

			tune_low = arr[3]
			tune_high = arr[4]
			filter_low = arr[5]
			filter_high = arr[6]
			layer_low = arr[7]
			layer_high = arr[8]
			attack_low = arr[9]
			attack_high = arr[10]
			decay_low = arr[11]
			decay_high = arr[12]

			{
				:pad => decode_slider_pad(arr[0]),
				:change => slider_change_decoded,
				:parameter => slider_change_decoded == :real_time ? decode_slider_real_time_parameter(arr[2]) : decode_slider_note_on_parameter(arr[2]),
				:tune_low => verified_param_value(:tune_low, tune_low, -120, tune_high),
				:tune_high => verified_param_value(:tune_high, tune_high, tune_low, 120),
				:filter_low => verified_param_value(:filter_low, filter_low, -50, filter_high),
				:filter_high => verified_param_value(:filter_high, filter_high, filter_low, 50),
				:layer_low => verified_param_value(:layer_low, layer_low, 0, layer_high),
				:layer_high => verified_param_value(:layer_high, layer_high, layer_low, 127),
				:attack_low => verified_param_value(:attack_low, attack_low, 0, attack_high),
				:attack_high => verified_param_value(:attack_high, attack_high, attack_low, 100),
				:decay_low => verified_param_value(:decay_low, decay_low, 0, decay_high),
				:decay_high => verified_param_value(:decay_high, decay_high, decay_low, 100),
			}
		end
		
		def pack_slider(slider)
			validate_keys("slider", slider, Defaults::SLIDER)
			slider_change = slider[:change]
			slider_parameter = slider[:parameter]

			tune_low = slider[:tune_low]
			tune_high = slider[:tune_high]
			filter_low = slider[:filter_low]
			filter_high = slider[:filter_high]
			layer_low = slider[:layer_low]
			layer_high = slider[:layer_high]
			attack_low = slider[:attack_low]
			attack_high = slider[:attack_high]
			decay_low = slider[:decay_low]
			decay_high = slider[:decay_high]

			[
				encode_slider_pad(slider[:pad]),
				encode_slider_change(slider_change),
				slider_change == :real_time ? encode_slider_real_time_parameter(slider_parameter) : encode_slider_note_on_parameter(slider_parameter),
				verified_param_value(:tune_low, tune_low, -120, tune_high),
				verified_param_value(:tune_high, tune_high, tune_low, 120),
				verified_param_value(:filter_low, filter_low, -50, filter_high),
				verified_param_value(:filter_high, filter_high, filter_low, 50),
				verified_param_value(:layer_low, layer_low, 0, layer_high),
				verified_param_value(:layer_high, layer_high, layer_low, 127),
				verified_param_value(:attack_low, attack_low, 0, attack_high),
				verified_param_value(:attack_high, attack_high, attack_low, 100),
				verified_param_value(:decay_low, decay_low, 0, decay_high),
				verified_param_value(:decay_high, decay_high, decay_low, 100),
			].pack("Cc12")
		end
		
		def unpack_slider_extra(str)
			arr = str.unpack("c2")
			slider_level_low = arr[0]
			slider_level_high = arr[1]
			{
				:slider_level_low => verified_param_value(:slider_level_low, slider_level_low, 0, slider_level_high),
				:slider_level_high => verified_param_value(:slider_level_high, slider_level_high, slider_level_low, 100),
			}
		end
		
		def pack_slider_extra(slider_extra)
			validate_keys("slider extra", slider_extra, Defaults::SLIDER_EXTRA)
			slider_level_low = slider_extra[:slider_level_low]
			slider_level_high = slider_extra[:slider_level_high]
			[
				verified_param_value(:slider_level_low, slider_level_low, 0, slider_level_high),
				verified_param_value(:slider_level_high, slider_level_high, slider_level_low, 100),
			].pack("c2")
		end
		
		def decode_program_play(c)
			case c
			when 0 then :poly
			when 1 then :mono
			when nil then
			 	raise "program play missing"
			else
			 	raise "bad program play: #{c}"
			end
		end
		
		def encode_program_play(program_play)
			case program_play
			when :poly then 0
			when :mono then 1
			when nil then
			 	raise "program play missing"
			else
			 	raise "bad program play: #{program_play}"
			end
		end
		
		def decode_decay_mode(c)
			case c
			when 0 then :end
			when 1 then :start
			when nil then
			 	raise "decay mode missing"
			else
			 	raise "bad decay mode: #{c}"
			end
		end
		
		def encode_decay_mode(decay_mode)
			case decay_mode
			when :end then 0
			when :start then 1
			when nil then
			 	raise "decay mode missing"
			else
			 	raise "bad decay mode: #{decay_mode}"
			end
		end
		
		def decode_voice_overlap(c)
			case c
			when 0 then :poly
			when 1 then :mono
			when nil then
			 	raise "voice overlap missing"
			else
			 	raise "bad voice overlap: #{c}"
			end
		end
		
		def encode_voice_overlap(voice_overlap)
			case voice_overlap
			when :poly then 0
			when :mono then 1
			when nil then
			 	raise "voice overlap missing"
			else
			 	raise "bad voice overlap: #{voice_overlap}"
			end
		end
		
		def decode_pad_filter1_type(c)
			case c
			when 0 then :off
			when 1 then :lowpass
			when 2 then :bandpass
			when 3 then :highpass
			when 4 then :lowpass2
			when nil then
			 	raise "pad filter 1 type missing"
			else
			 	raise "bad pad filter 1 type: #{c}"
			end
		end
		
		def encode_pad_filter1_type(value)
			case value
			when :off then 0
			when :lowpass then 1
			when :bandpass then 2
			when :highpass then 3
			when :lowpass2 then 4
			when nil then
			 	raise "pad filter 1 type missing"
			else
			 	raise "bad pad filter 1 type: #{value}"
			end
		end

		def decode_pad_filter2_type(c)
			case c
			when 0 then :off
			when 1 then :lowpass
			when 2 then :bandpass
			when 3 then :highpass
			when 4 then :lowpass2
			when 5 then :link
			when nil then
			 	raise "pad filter 2 type missing"
			else
			 	raise "bad pad filter 2 type: #{c}"
			end
		end
		
		def encode_pad_filter2_type(value)
			case value
			when :off then 0
			when :lowpass then 1
			when :bandpass then 2
			when :highpass then 3
			when :lowpass2 then 4
			when :link then 5
			when nil then
			 	raise "pad filter 2 type missing"
			else
			 	raise "bad pad filter 2 type: #{value}"
			end
		end
		
		def decode_pad_output(c)
			case c
			when 0 then :stereo
			when 1 then :alt12
			when 2 then :alt34
			when nil then
			 	raise "pad output missing"
			else
			 	raise "bad pad output: #{c}"
			end
		end
		
		def encode_pad_output(pad_output)
			case pad_output
			when :stereo then 0
			when :alt12 then 1
			when :alt34 then 2
			when nil then
			 	raise "pad output missing"
			else
			 	raise "bad pad output: #{pad_output}"
			end
		end
		
		def decode_lfo_wave(c)
			case c
			when 0 then :triangle
			when 1 then :sine
			when 2 then :square
			when 3 then :saw
			when 4 then :saw_down
			when 5 then :random
			when nil then
			 	raise "lfo wave missing"
			else
			 	raise "bad lfo wave: #{c}"
			end
		end
		
		def encode_lfo_wave(value)
			case value
			when :triangle then 0
			when :sine then 1
			when :square then 2
			when :saw then 3
			when :saw_down then 4
			when :random then 5
			when nil then
			 	raise "lfo wave missing"
			else
			 	raise "bad lfo wave: #{value}"
			end
		end
		
		def decode_pad_fx_send(c)
			case c
			when 0 then :off
			when 1 then :send1
			when 2 then :send2
			when nil then
			 	raise "pad fx send missing"
			else
			 	raise "bad pad fx send: #{c}"
			end
		end
		
		def encode_pad_fx_send(pad_fx_send)
			case pad_fx_send
			when :off then 0
			when :send1 then 1
			when :send2 then 2
			when nil then
			 	raise "pad fx send missing"
			else
			 	raise "bad pad fx send: #{pad_fx_send}"
			end
		end
		
		def decode_pad_filter_attenuation(c)
			case c
			when 0 then :zerodb
			when 1 then :minus6db
			when 2 then :minus12db
			when nil then
			 	raise "pad filter attenuation missing"
			else
			 	raise "bad pad filter attenuation: #{c}"
			end
		end
		
		def encode_pad_filter_attenuation(pad_filter_attenuation)
			case pad_filter_attenuation
			when :zerodb then 0
			when :minus6db then 1
			when :minus12db then 2
			when nil then
			 	raise "pad filter attenuation missing"
			else
			 	raise "bad pad filter attenuation: #{pad_filter_attenuation}"
			end
		end
		
		def decode_play_mode(c)
			case c
			when 0 then :one_shot
			when 1 then :note_on
			when nil then
			 	raise "play mode missing"
			else
			 	raise "bad play mode: #{c}"
			end
		end
		
		def encode_play_mode(play_mode)
			case play_mode
			when :one_shot then 0
			when :note_on then 1
			when nil then
			 	raise "play mode missing"
			else
			 	raise "bad play mode: #{play_mode}"
			end
		end
		
		def decode_velocity_to_pitch(c)
			case c
			when 0..100 then
				c
			when nil then
			 	raise "velocity to pitch missing"
			else
			 	raise "bad velocity to pitch: #{c}"
			end
		end
		
		def encode_velocity_to_pitch(velocity_to_pitch)
			case velocity_to_pitch
			when 0..100 then
				velocity_to_pitch
			when nil then
			 	raise "velocity to pitch missing"
			else
			 	raise "bad velocity to pitch: #{velocity_to_pitch}"
			end
		end
		
		def decode_midi_note_pad_value(c)
			case c
			when 0..63 then c
			when 64 then :unassigned
			when nil then
			 	raise "midi note pad value missing"
			else
			 	raise "bad midi note pad value: #{c}"
			end
		end
		
		def encode_midi_note_pad_value(value)
			case value
			when 0..63 then value
			when :unassigned then 64
			when nil then
			 	raise "midi note pad value missing"
			else
			 	raise "bad midi note pad value: #{value}"
			end
		end
		
		def decode_mute_target(c)
			case c
			when 0 then :off
			when 1..64 then c-1
			when nil then
			 	raise "mute target missing"
			else
			 	raise "bad mute target: #{c}"
			end
		end
		
		def encode_mute_target(value)
			case value
			when :off then 0
			when 0..63 then value+1
			when nil then
			 	raise "mute target missing"
			else
			 	raise "bad mute target: #{value}"
			end
		end
		
		def decode_slider_pad(c)
			case c
			when 0 then :off
			when 1..64 then c-1
			when nil then
			 	raise "slider pad missing"
			else
			 	raise "bad slider pad: #{c}"
			end
		end
		
		def encode_slider_pad(value)
			case value
			when :off then 0
			when 0..63 then value+1
			when nil then
			 	raise "slider pad missing"
			else
			 	raise "bad slider pad: #{value}"
			end
		end
		
		def decode_mute_group(c)
			case c
			when 0 then :off
			when 1..32 then c
			when nil then
			 	raise "mute group missing"
			else
			 	raise "bad mute group: #{c}"
			end
		end
		
		def encode_mute_group(mute_group)
			case mute_group
			when :off then 0
			when 1..32 then mute_group
			when nil then
			 	raise "mute group missing"
			else
			 	raise "bad mute group: #{mute_group}"
			end
		end
		
		def decode_midi_program_change(c)
			case c
			when 0 then :off
			when nil then
			 	raise "midi program change missing"
			else c
			end
		end
		
		def encode_midi_program_change(midi_program_change)
			case midi_program_change
			when :off then 0
			when nil then
			 	raise "midi program change missing"
			else midi_program_change
			end
		end
		
		def decode_slider_change(c)
			case c
			when 0 then :real_time
			when 1 then :note_on
			when nil then
			 	raise "slider change missing"
			else
			 	raise "bad slider change: #{c}"
			end
		end
		
		def encode_slider_change(slider_change)
			case slider_change
			when :real_time then 0
			when :note_on then 1
			when nil then
			 	raise "slider change missing"
			else
			 	raise "bad slider change: #{slider_parameter}"
			end
		end

		def decode_slider_real_time_parameter(c)
			case c
			when 0 then :tune
			when 1 then :cutoff_12
			when 5 then :level
			when 6 then :cutoff_1
			when 7 then :cutoff_2
			when 8 then :reso_12
			when 9 then :reso_1
			when 10 then :reso_2
			when 11 then :pan
			when nil then
			 	raise "slider real time parameter missing"
			else
			 	raise "bad slider real time parameter: #{c}"
			end
		end
		
		def encode_slider_real_time_parameter(slider_parameter)
			case slider_parameter
			when :tune then 0
			when :cutoff_12 then 1
			when :level then 5
			when :cutoff_1 then 6
			when :cutoff_2 then 7
			when :reso_12 then 8
			when :reso_1 then 9
			when :reso_2 then 10
			when :pan then 11
			when nil then
			 	raise "slider real time parameter missing"
			else
			 	raise "bad slider real time parameter: #{slider_parameter}"
			end
		end

		def decode_slider_note_on_parameter(c)
			case c
			when 0 then :tune
			when 1 then :filter
			when 2 then :layer
			when 3 then :attack
			when 4 then :decay
			when nil then
			 	raise "slider note on parameter missing"
			else
			 	raise "bad slider note on parameter: #{c}"
			end
		end
		
		def encode_slider_note_on_parameter(slider_parameter)
			case slider_parameter
			when :tune then 0
			when :filter then 1
			when :layer then 2
			when :attack then 3
			when :decay then 4
			when nil then
			 	raise "slider note on parameter missing"
			else
			 	raise "bad slider note on parameter: #{slider_parameter}"
			end
		end

		def verified_param_value(param_name, param_value, lowest_value, highest_value)
			case param_value
			when lowest_value..highest_value then param_value
			when nil
			 	raise "value for parameter #{param_name} missing"
			else
			 	raise "value #{param_value} for parameter #{param_name} not within range #{low}..#{highest_value}"
			end
		end

		def verified_string(param_name, param_string, length)
			if param_string.size < length
				param_string
			elsif param_string == nil
			 	raise "value for parameter #{param_name} missing"
			else
			 	raise "string \"#{param_string}\" for parameter #{param_name} exceeds length #{length}"
			end
		end
	end
end
