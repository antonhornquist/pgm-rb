require 'test/unit'
require 'base64'
require 'pgm'

BASE64_ENCODED_PGM_FILE = <<EOF
BCoAAE1QQzEwMDAgUEdNIDEuMDAAAAAAODA4IEtpY2tfbG9uZwAAAABkAH8A
AAAAAEpfUlVCUwAAAAAAAAAAAABGAH8AAAAAAEpfUlVCUwAAAAAAAAAAAABG
AH8AAAAAAAAAAAAAAAAAAAAAAAAAAABGAH8AAAAAAAAAAAABAAUAAABkAAAA
AAABZAAAAAAAAABkAAAAAAAAAAAAAAAAAAAAAAAAAABkMgAAJAAAAAAAAAAA
AAAAAAAAAAA4MDggU25hcmVfbG8xAAAAAGRGfwAAAAA4MDggU25hcmVfbG8y
AAAAAGQeUAAAAAA4MDggU25hcmVfbG8zAAAAAGQAfwAAAAAAAAAAAAAAAAAA
AAAAAAAAAEYAfwAAAAAAAAAAAAEABQAAAGQAAAAAAAFkAAAAAAAAAGQAAAAA
AAAAAAAAAAAAAAAAAAAAAGQyAAARAAAAAAAAAAAAAAAAAAAAADgwOCBIYXRf
Y2xvc2VkAAAAUAB/AAAAAAAAAAAAAAAAAAAAAAAAAAAARgB/AAAAAAAAAAAA
AAAAAAAAAAAAAAAARgB/AAAAAAAAAAAAAAAAAAAAAAAAAAAARgB/AAAAAAAA
AAEAAQAFAAAAZAAAAAAAAWQAAAAAAAAAZAAAAAAAAAAAAAAAAAAAAAAAAAAA
ZBkAAAAAAAAAAAAAAAAAAAAAAAAAODA4IENvd2JlbGwAaWdoAABkAH8AAAAA
AAAAAAAAAAAAAAAAAAAAAABGAH8AAAAAAAAAAAAAAAAAAAAAAAAAAABGAH8A
AAAAAAAAAAAAAAAAAAAAAAAAAABGAH8AAAAAAAAAAAABAAUAAABkAAAAAAAB
ZAAAAAAAAABkAAAAAAAAAAAAAAAAAAAAAAAAAABkMgAAHgAAAAAAAAAAAAAA
AAAAAAA4MDggQ2xhcABfbG8zAAAAAGQAfwAAAAAAAAAAAAAAAAAAAAAAAAAA
AEYAfwAAAAAAAAAAAAAAAAAAAAAAAAAAAEYAfwAAAAAAAAAAAAAAAAAAAAAA
AAAAAEYAfwAAAAAAAAAAAAEABQAAAGQAAAAAAAFkAAAAAAAAAGQAAAAAAAAA
AAAAAAAAAAAAAAAAAGQyAAAeAAAAAAAAAAAAAAAAAAAAADgwOCBIYXRfbG9u
ZwBkAAAASwB/AAAAAAAAAAAAAAAAAAAAAAAAAAAARgB/AAAAAAAAAAAAAAAA
AAAAAAAAAAAARgB/AAAAAAAAAAAAAAAAAAAAAAAAAAAARgB/AAAAAAAAAAEA
AQAFAAAAZAAAAAAAAWQAAAAAAAAAZAAAAAAAAAAAAAAAAAAAAAAAAAAAZBkA
ABQAAAAAAAAAAAAAAAAAAAAAODA4IFJpbXNob3QAAAAAAABkAH8AAAAAAAAA
AAAAAAAAAAAAAAAAAABGAH8AAAAAAAAAAAAAAAAAAAAAAAAAAABGAH8AAAAA
AAAAAAAAAAAAAAAAAAAAAABGAH8AAAAAAAAAAAABAAUAAABkAAAAAAABZAAA
AAAAAABkAAAAAAAAAAAAAAAAAAAAAAAAAABkJwAAEQAAAAAAAAAAAAAAAAAA
AAA4MDggQ2xhdmUALWhpZ2gAAGQAfwAAAAAAAAAAAAAAAAAAAAAAAAAAAEYA
fwAAAAAAAAAAAAAAAAAAAAAAAAAAAEYAfwAAAAAAAAAAAAAAAAAAAAAAAAAA
AEYAfwAAAAAAAAAAAAEABQAAAGQAAAAAAAFkAAAAAAAAAGQAAAAAAAAAAAAA
AAAAAAAAAAAAAGRDAAARAAAAAAAAAAAAAAAAAAAAADgwOCBDeW1iYWwtaGln
aAAAUAB/AAAAAAAAAAAAAAAAAAAAAAAAAAAARgB/AAAAAAAAAAAAAAAAAAAA
AAAAAAAARgB/AAAAAAAAAAAAAAAAAAAAAAAAAAAARgB/AAAAAAAAAAAAAQAF
AAAAZAAAAAAAAWQAAAAAAAAAZAAAAAAAAAAAAAAAAAAAAAAAAAAAZCMAABcA
AAAAAAAAAAAAAAAAAAAAODA4IExvIFRvbQAAAAAAAABkAH8AAAAAAAAAAAAA
AAAAAAAAAAAAAABGAH8AAAAAAAAAAAAAAAAAAAAAAAAAAABGAH8AAAAAAAAA
AAAAAAAAAAAAAAAAAABGAH8AAAAAAAAAAAABAAUAAABkAAAAAAABZAAAAAAA
AABkAAAAAAAAAAAAAAAAAAAAAAAAAABkGAAAFwAAAAAAAAAAAAAAAAAAAAA4
MDggTWQgVG9tAAAAAAAAAGQAfwAAAAAAAAAAAAAAAAAAAAAAAAAAAEYAfwAA
AAAAAAAAAAAAAAAAAAAAAAAAAEYAfwAAAAAAAAAAAAAAAAAAAAAAAAAAAEYA
fwAAAAAAAAAAAAEABQAAAGQAAAAAAAFkAAAAAAAAAGQAAAAAAAAAAAAAAAAA
AAAAAAAAAGQyAAAUAAAAAAAAAAAAAAAAAAAAADgwOCBIaSBUb20AAAAAAAAA
ZAB/AAAAAAAAAAAAAAAAAAAAAAAAAAAARgB/AAAAAAAAAAAAAAAAAAAAAAAA
AAAARgB/AAAAAAAAAAAAAAAAAAAAAAAAAAAARgB/AAAAAAAAAAAAAQAFAAAA
ZAAAAAAAAWQAAAAAAAAAZAAAAAAAAAAAAAAAAAAAAAAAAAAAZE0AACEAAAAA
AAAAAAAAAAAAAAAAODA4IExvIENvbmdhAAAAAABkAH8AAAAAAAAAAAAAAAAA
AAAAAAAAAABGAH8AAAAAAAAAAAAAAAAAAAAAAAAAAABGAH8AAAAAAAAAAAAA
AAAAAAAAAAAAAABGAH8AAAAAAAAAAAABAAUAAABkAAAAAAABZAAAAAAAAABk
AAAAAAAAAAAAAAAAAAAAAAAAAABkFwAAIQAAAAAAAAAAAAAAAAAAAAA4MDgg
TWQgQ29uZ2EAAAAAAGQAfwAAAAAAAAAAAAAAAAAAAAAAAAAAAEYAfwAAAAAA
AAAAAAAAAAAAAAAAAAAAAEYAfwAAAAAAAAAAAAAAAAAAAAAAAAAAAEYAfwAA
AAAAAAAAAAEABQAAAGQAAAAAAAFkAAAAAAAAAGQAAAAAAAAAAAAAAAAAAAAA
AAAAAGQXAAAhAAAAAAAAAAAAAAAAAAAAADgwOCBIaSBDb25nYQAAAAAAZAB/
AAAAAAAAAAAAAAAAAAAAAAAAAAAARgB/AAAAAAAAAAAAAAAAAAAAAAAAAAAA
RgB/AAAAAAAAAAAAAAAAAAAAAAAAAAAARgB/AAAAAAAAAAAAAQAFAAAAZAAA
AAAAAWQAAAAAAAAAZAAAAAAAAAAAAAAAAAAAAAAAAAAAZE0AAAsAAAAAAAAA
AAAAAAAAAAAAODA4IEtpY2tfbG9uZwAAAABkAH8AAAAAAAAAAAAAAAAAAAAA
AAAAAABGAH8AAAAAAAAAAAAAAAAAAAAAAAAAAABGAH8AAAAAAAAAAAAAAAAA
AAAAAAAAAABGAH8AAAAAAAAAAAABACMBAABkAAAAAAABZAAAAAAAAABkAAAA
AAAAAAAAAAAAAAAAAAAAAABkMgAAIQAAAAAAAAAAAAAAAAAAAAA4MDggS2lj
a19sb25nAAAAAGQAfwAAAAAAAAAAAAAAAAAAAAAAAAAAAEYAfwAAAAAAAAAA
AAAAAAAAAAAAAAAAAEYAfwAAAAAAAAAAAAAAAAAAAAAAAAAAAEYAfwAAAAAA
AAAAAAEAMgEAAGQAAAAAAAFkAAAAAAAAAGQAAAAAAAAAAAAAAAAAAAAAAAAA
AGQyAAASAAAAAAAAAAAAAAAAAAAAADgwOCBLaWNrX2xvbmcAAAAAZAB/AAAA
AAAAAAAAAAAAAAAAAAAAAAAARgB/AAAAAAAAAAAAAAAAAAAAAAAAAAAARgB/
AAAAAAAAAAAAAAAAAAAAAAAAAAAARgB/AAAAAAAAAAAAAQBLAQAAZAAAAAAA
AWQAAAAAAAAAZAAAAAAAAAAAAAAAAAAAAAAAAAAAZDIAABAAAAAAAAAAAAAA
AAAAAAAAAEpfUlVCUwAAAAAAAAAAAABkAH8AAAAAAAAAAAAAAAAAAAAAAAAA
AABGAH8AAAAAAAAAAAAAAAAAAAAAAAAAAABGAH8AAAAAAAAAAAAAAAAAAAAA
AAAAAABGAH8AAAAAAAAAAAABAAUAAABkAAAAAAABZAAAAAAAAABkAAAAAAAA
AAAAAAAAAAAAAAAAAABkMgAAIQAAAAAAAAAAAAAAAAAAAAAASl9SVUJTAAAA
AAAAAAAAAEYAfwAAAAAAAAAAAAAAAAAAAAAAAAAAAEYAfwAAAAAAAAAAAAAA
AAAAAAAAAAAAAEYAfwAAAAAAAAAAAAAAAAAAAAAAAAAAAEYAfwAAAAAAAAAA
AAEABQAAAGQAAAAAAAFkAAAAAAAAAGQAAAAAAAAAAAAAAAAAAAAAAAAAAGRQ
AAAGAAAAAAAAAAAAAAAAAAAAAABKX1JVQlMAAAAAAAAAAAAARgB/AAAAAAAA
AAAAAAAAAAAAAAAAAAAARgB/AAAAAAAAAAAAAAAAAAAAAAAAAAAARgB/AAAA
AAAAAAAAAAAAAAAAAAAAAAAARgB/AAAAAAAAAAAAAQAFAAAAZAAAAAAAAWQA
AAAAAAAAZAAAAAAAAAAAAAAAAAAAAAAAAAAAZDIAACEAAAAAAAAAAAAAAAAA
AAAAAAAAAAAAAAAAAAAAAAAAAABGAH8AAAAAAAAAAAAAAAAAAAAAAAAAAABG
AH8AAAAAAAAAAAAAAAAAAAAAAAAAAABGAH8AAAAAAAAAAAAAAAAAAAAAAAAA
AABGAH8AAAAAAAAAAAABAAUAAABkAAAAAAABZAAAAAAAAABkAAAAAAAAAAAA
AAAAAAAAAAAAAABkMgAAIQAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAA
AAAAAEYAfwAAAAAAAAAAAAAAAAAAAAAAAAAAAEYAfwAAAAAAAAAAAAAAAAAA
AAAAAAAAAEYAfwAAAAAAAAAAAAAAAAAAAAAAAAAAAEYAfwAAAAAAAAAAAAEA
BQAAAGQAAAAAAAFkAAAAAAAAAGQAAAAAAAAAAAAAAAAAAAAAAAAAAGQyAAAh
AAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAARgB/AAAAAAAAAAAA
AAAAAAAAAAAAAAAARgB/AAAAAAAAAAAAAAAAAAAAAAAAAAAARgB/AAAAAAAA
AAAAAAAAAAAAAAAAAAAARgB/AAAAAAAAAAAAAQAFAAAAZAAAAAAAAWQAAAAA
AAAAZAAAAAAAAAAAAAAAAAAAAAAAAAAAZDIAACEAAAAAAAAAAAAAAAAAAAAA
AAAAAAAAAAAAAAAAAAAAAABGAH8AAAAAAAAAAAAAAAAAAAAAAAAAAABGAH8A
AAAAAAAAAAAAAAAAAAAAAAAAAABGAH8AAAAAAAAAAAAAAAAAAAAAAAAAAABG
AH8AAAAAAAAAAAABAAUAAABkAAAAAAABZAAAAAAAAABkAAAAAAAAAAAAAAAA
AAAAAAAAAABkMgAAIQAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAA
AEYAfwAAAAAAAAAAAAAAAAAAAAAAAAAAAEYAfwAAAAAAAAAAAAAAAAAAAAAA
AAAAAEYAfwAAAAAAAAAAAAAAAAAAAAAAAAAAAEYAfwAAAAAAAAAAAAEABQAA
AGQAAAAAAAFkAAAAAAAAAGQAAAAAAAAAAAAAAAAAAAAAAAAAAGQyAAAhAAAA
AAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAARgB/AAAAAAAAAAAAAAAA
AAAAAAAAAAAARgB/AAAAAAAAAAAAAAAAAAAAAAAAAAAARgB/AAAAAAAAAAAA
AAAAAAAAAAAAAAAARgB/AAAAAAAAAAAAAQAFAAAAZAAAAAAAAWQAAAAAAAAA
ZAAAAAAAAAAAAAAAAAAAAAAAAAAAZDIAACEAAAAAAAAAAAAAAAAAAAAAAAAA
AAAAAAAAAAAAAAAAAABGAH8AAAAAAAAAAAAAAAAAAAAAAAAAAABGAH8AAAAA
AAAAAAAAAAAAAAAAAAAAAABGAH8AAAAAAAAAAAAAAAAAAAAAAAAAAABGAH8A
AAAAAAAAAAABAAUAAABkAAAAAAABZAAAAAAAAABkAAAAAAAAAAAAAAAAAAAA
AAAAAABkMgAAIQAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAEYA
fwAAAAAAAAAAAAAAAAAAAAAAAAAAAEYAfwAAAAAAAAAAAAAAAAAAAAAAAAAA
AEYAfwAAAAAAAAAAAAAAAAAAAAAAAAAAAEYAfwAAAAAAAAAAAAEABQAAAGQA
AAAAAAFkAAAAAAAAAGQAAAAAAAAAAAAAAAAAAAAAAAAAAGQyAAAhAAAAAAAA
AAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAARgB/AAAAAAAAAAAAAAAAAAAA
AAAAAAAARgB/AAAAAAAAAAAAAAAAAAAAAAAAAAAARgB/AAAAAAAAAAAAAAAA
AAAAAAAAAAAARgB/AAAAAAAAAAAAAQAFAAAAZAAAAAAAAWQAAAAAAAAAZAAA
AAAAAAAAAAAAAAAAAAAAAAAAZDIAACEAAAAAAAAAAAAAAAAAAAAAAAAAAAAA
AAAAAAAAAAAAAABGAH8AAAAAAAAAAAAAAAAAAAAAAAAAAABGAH8AAAAAAAAA
AAAAAAAAAAAAAAAAAABGAH8AAAAAAAAAAAAAAAAAAAAAAAAAAABGAH8AAAAA
AAAAAAABAAUAAABkAAAAAAABZAAAAAAAAABkAAAAAAAAAAAAAAAAAAAAAAAA
AABkMgAAIQAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAEYAfwAA
AAAAAAAAAAAAAAAAAAAAAAAAAEYAfwAAAAAAAAAAAAAAAAAAAAAAAAAAAEYA
fwAAAAAAAAAAAAAAAAAAAAAAAAAAAEYAfwAAAAAAAAAAAAEABQAAAGQAAAAA
AAFkAAAAAAAAAGQAAAAAAAAAAAAAAAAAAAAAAAAAAGQyAAAhAAAAAAAAAAAA
AAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAARgB/AAAAAAAAAAAAAAAAAAAAAAAA
AAAARgB/AAAAAAAAAAAAAAAAAAAAAAAAAAAARgB/AAAAAAAAAAAAAAAAAAAA
AAAAAAAARgB/AAAAAAAAAAAAAQAFAAAAZAAAAAAAAWQAAAAAAAAAZAAAAAAA
AAAAAAAAAAAAAAAAAAAAZDIAACEAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAA
AAAAAAAAAABGAH8AAAAAAAAAAAAAAAAAAAAAAAAAAABGAH8AAAAAAAAAAAAA
AAAAAAAAAAAAAABGAH8AAAAAAAAAAAAAAAAAAAAAAAAAAABGAH8AAAAAAAAA
AAABAAUAAABkAAAAAAABZAAAAAAAAABkAAAAAAAAAAAAAAAAAAAAAAAAAABk
MgAAIQAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAEYAfwAAAAAA
AAAAAAAAAAAAAAAAAAAAAEYAfwAAAAAAAAAAAAAAAAAAAAAAAAAAAEYAfwAA
AAAAAAAAAAAAAAAAAAAAAAAAAEYAfwAAAAAAAAAAAAEABQAAAGQAAAAAAAFk
AAAAAAAAAGQAAAAAAAAAAAAAAAAAAAAAAAAAAGQyAAAhAAAAAAAAAAAAAAAA
AAAAAAAAAAAAAAAAAAAAAAAAAAAARgB/AAAAAAAAAAAAAAAAAAAAAAAAAAAA
RgB/AAAAAAAAAAAAAAAAAAAAAAAAAAAARgB/AAAAAAAAAAAAAAAAAAAAAAAA
AAAARgB/AAAAAAAAAAAAAQAFAAAAZAAAAAAAAWQAAAAAAAAAZAAAAAAAAAAA
AAAAAAAAAAAAAAAAZDIAACEAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAA
AAAAAABGAH8AAAAAAAAAAAAAAAAAAAAAAAAAAABGAH8AAAAAAAAAAAAAAAAA
AAAAAAAAAABGAH8AAAAAAAAAAAAAAAAAAAAAAAAAAABGAH8AAAAAAAAAAAAB
AAUAAABkAAAAAAABZAAAAAAAAABkAAAAAAAAAAAAAAAAAAAAAAAAAABkMgAA
IQAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAEYAfwAAAAAAAAAA
AAAAAAAAAAAAAAAAAEYAfwAAAAAAAAAAAAAAAAAAAAAAAAAAAEYAfwAAAAAA
AAAAAAAAAAAAAAAAAAAAAEYAfwAAAAAAAAAAAAEABQAAAGQAAAAAAAFkAAAA
AAAAAGQAAAAAAAAAAAAAAAAAAAAAAAAAAGQyAAAhAAAAAAAAAAAAAAAAAAAA
AAAAAAAAAAAAAAAAAAAAAAAARgB/AAAAAAAAAAAAAAAAAAAAAAAAAAAARgB/
AAAAAAAAAAAAAAAAAAAAAAAAAAAARgB/AAAAAAAAAAAAAAAAAAAAAAAAAAAA
RgB/AAAAAAAAAAAAAQAFAAAAZAAAAAAAAWQAAAAAAAAAZAAAAAAAAAAAAAAA
AAAAAAAAAAAAZDIAACEAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAA
AABGAH8AAAAAAAAAAAAAAAAAAAAAAAAAAABGAH8AAAAAAAAAAAAAAAAAAAAA
AAAAAABGAH8AAAAAAAAAAAAAAAAAAAAAAAAAAABGAH8AAAAAAAAAAAABAAUA
AABkAAAAAAABZAAAAAAAAABkAAAAAAAAAAAAAAAAAAAAAAAAAABkMgAAIQAA
AAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAEYAfwAAAAAAAAAAAAAA
AAAAAAAAAAAAAEYAfwAAAAAAAAAAAAAAAAAAAAAAAAAAAEYAfwAAAAAAAAAA
AAAAAAAAAAAAAAAAAEYAfwAAAAAAAAAAAAEABQAAAGQAAAAAAAFkAAAAAAAA
AGQAAAAAAAAAAAAAAAAAAAAAAAAAAGQyAAAhAAAAAAAAAAAAAAAAAAAAAAAA
AAAAAAAAAAAAAAAAAAAARgB/AAAAAAAAAAAAAAAAAAAAAAAAAAAARgB/AAAA
AAAAAAAAAAAAAAAAAAAAAAAARgB/AAAAAAAAAAAAAAAAAAAAAAAAAAAARgB/
AAAAAAAAAAAAAQAFAAAAZAAAAAAAAWQAAAAAAAAAZAAAAAAAAAAAAAAAAAAA
AAAAAAAAZDIAACEAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAABG
AH8AAAAAAAAAAAAAAAAAAAAAAAAAAABGAH8AAAAAAAAAAAAAAAAAAAAAAAAA
AABGAH8AAAAAAAAAAAAAAAAAAAAAAAAAAABGAH8AAAAAAAAAAAABAAUAAABk
AAAAAAABZAAAAAAAAABkAAAAAAAAAAAAAAAAAAAAAAAAAABkMgAAIQAAAAAA
AAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAEYAfwAAAAAAAAAAAAAAAAAA
AAAAAAAAAEYAfwAAAAAAAAAAAAAAAAAAAAAAAAAAAEYAfwAAAAAAAAAAAAAA
AAAAAAAAAAAAAEYAfwAAAAAAAAAAAAEABQAAAGQAAAAAAAFkAAAAAAAAAGQA
AAAAAAAAAAAAAAAAAAAAAAAAAGQyAAAhAAAAAAAAAAAAAAAAAAAAAAAAAAAA
AAAAAAAAAAAAAAAARgB/AAAAAAAAAAAAAAAAAAAAAAAAAAAARgB/AAAAAAAA
AAAAAAAAAAAAAAAAAAAARgB/AAAAAAAAAAAAAAAAAAAAAAAAAAAARgB/AAAA
AAAAAAAAAQAFAAAAZAAAAAAAAWQAAAAAAAAAZAAAAAAAAAAAAAAAAAAAAAAA
AAAAZDIAACEAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAABGAH8A
AAAAAAAAAAAAAAAAAAAAAAAAAABGAH8AAAAAAAAAAAAAAAAAAAAAAAAAAABG
AH8AAAAAAAAAAAAAAAAAAAAAAAAAAABGAH8AAAAAAAAAAAABAAUAAABkAAAA
AAABZAAAAAAAAABkAAAAAAAAAAAAAAAAAAAAAAAAAABkMgAAIQAAAAAAAAAA
AAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAEYAfwAAAAAAAAAAAAAAAAAAAAAA
AAAAAEYAfwAAAAAAAAAAAAAAAAAAAAAAAAAAAEYAfwAAAAAAAAAAAAAAAAAA
AAAAAAAAAEYAfwAAAAAAAAAAAAEABQAAAGQAAAAAAAFkAAAAAAAAAGQAAAAA
AAAAAAAAAAAAAAAAAAAAAGQyAAAhAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAA
AAAAAAAAAAAARgB/AAAAAAAAAAAAAAAAAAAAAAAAAAAARgB/AAAAAAAAAAAA
AAAAAAAAAAAAAAAARgB/AAAAAAAAAAAAAAAAAAAAAAAAAAAARgB/AAAAAAAA
AAAAAQAFAAAAZAAAAAAAAWQAAAAAAAAAZAAAAAAAAAAAAAAAAAAAAAAAAAAA
ZDIAACEAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAABGAH8AAAAA
AAAAAAAAAAAAAAAAAAAAAABGAH8AAAAAAAAAAAAAAAAAAAAAAAAAAABGAH8A
AAAAAAAAAAAAAAAAAAAAAAAAAABGAH8AAAAAAAAAAAABAAUAAABkAAAAAAAB
ZAAAAAAAAABkAAAAAAAAAAAAAAAAAAAAAAAAAABkMgAAIQAAAAAAAAAAAAAA
AAAAAAAAAAAAAAAAAAAAAAAAAAAAAEYAfwAAAAAAAAAAAAAAAAAAAAAAAAAA
AEYAfwAAAAAAAAAAAAAAAAAAAAAAAAAAAEYAfwAAAAAAAAAAAAAAAAAAAAAA
AAAAAEYAfwAAAAAAAAAAAAEABQAAAGQAAAAAAAFkAAAAAAAAAGQAAAAAAAAA
AAAAAAAAAAAAAAAAAGQyAAAhAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAA
AAAAAAAARgB/AAAAAAAAAAAAAAAAAAAAAAAAAAAARgB/AAAAAAAAAAAAAAAA
AAAAAAAAAAAARgB/AAAAAAAAAAAAAAAAAAAAAAAAAAAARgB/AAAAAAAAAAAA
AQAFAAAAZAAAAAAAAWQAAAAAAAAAZAAAAAAAAAAAAAAAAAAAAAAAAAAAZDIA
ACEAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAABGAH8AAAAAAAAA
AAAAAAAAAAAAAAAAAABGAH8AAAAAAAAAAAAAAAAAAAAAAAAAAABGAH8AAAAA
AAAAAAAAAAAAAAAAAAAAAABGAH8AAAAAAAAAAAABAAUAAABkAAAAAAABZAAA
AAAAAABkAAAAAAAAAAAAAAAAAAAAAAAAAABkMgAAIQAAAAAAAAAAAAAAAAAA
AAAAAAAAAAAAAAAAAAAAAAAAAEYAfwAAAAAAAAAAAAAAAAAAAAAAAAAAAEYA
fwAAAAAAAAAAAAAAAAAAAAAAAAAAAEYAfwAAAAAAAAAAAAAAAAAAAAAAAAAA
AEYAfwAAAAAAAAAAAAEABQAAAGQAAAAAAAFkAAAAAAAAAGQAAAAAAAAAAAAA
AAAAAAAAAAAAAGQyAAAhAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAA
AAAARgB/AAAAAAAAAAAAAAAAAAAAAAAAAAAARgB/AAAAAAAAAAAAAAAAAAAA
AAAAAAAARgB/AAAAAAAAAAAAAAAAAAAAAAAAAAAARgB/AAAAAAAAAAAAAQAF
AAAAZAAAAAAAAWQAAAAAAAAAZAAAAAAAAAAAAAAAAAAAAAAAAAAAZDIAACEA
AAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAABGAH8AAAAAAAAAAAAA
AAAAAAAAAAAAAABGAH8AAAAAAAAAAAAAAAAAAAAAAAAAAABGAH8AAAAAAAAA
AAAAAAAAAAAAAAAAAABGAH8AAAAAAAAAAAABAAUAAABkAAAAAAABZAAAAAAA
AABkAAAAAAAAAAAAAAAAAAAAAAAAAABkMgAAIQAAAAAAAAAAAAAAAAAAAAAA
AAAAAAAAAAAAAAAAAAAAAEYAfwAAAAAAAAAAAAAAAAAAAAAAAAAAAEYAfwAA
AAAAAAAAAAAAAAAAAAAAAAAAAEYAfwAAAAAAAAAAAAAAAAAAAAAAAAAAAEYA
fwAAAAAAAAAAAAEABQAAAGQAAAAAAAFkAAAAAAAAAGQAAAAAAAAAAAAAAAAA
AAAAAAAAAGQyAAAhAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAA
RgB/AAAAAAAAAAAAAAAAAAAAAAAAAAAARgB/AAAAAAAAAAAAAAAAAAAAAAAA
AAAARgB/AAAAAAAAAAAAAAAAAAAAAAAAAAAARgB/AAAAAAAAAAAAAQAFAAAA
ZAAAAAAAAWQAAAAAAAAAZAAAAAAAAAAAAAAAAAAAAAAAAAAAZDIAACEAAAAA
AAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAABGAH8AAAAAAAAAAAAAAAAA
AAAAAAAAAABGAH8AAAAAAAAAAAAAAAAAAAAAAAAAAABGAH8AAAAAAAAAAAAA
AAAAAAAAAAAAAABGAH8AAAAAAAAAAAABAAUAAABkAAAAAAABZAAAAAAAAABk
AAAAAAAAAAAAAAAAAAAAAAAAAABkMgAAIQAAAAAAAAAAAAAAAAAAAAAAAAAA
AAAAAAAAAAAAAAAAAEYAfwAAAAAAAAAAAAAAAAAAAAAAAAAAAEYAfwAAAAAA
AAAAAAAAAAAAAAAAAAAAAEYAfwAAAAAAAAAAAAAAAAAAAAAAAAAAAEYAfwAA
AAAAAAAAAAEABQAAAGQAAAAAAAFkAAAAAAAAAGQAAAAAAAAAAAAAAAAAAAAA
AAAAAGQyAAAhAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAARgB/
AAAAAAAAAAAAAAAAAAAAAAAAAAAARgB/AAAAAAAAAAAAAAAAAAAAAAAAAAAA
RgB/AAAAAAAAAAAAAAAAAAAAAAAAAAAARgB/AAAAAAAAAAAAAQAFAAAAZAAA
AAAAAWQAAAAAAAAAZAAAAAAAAAAAAAAAAAAAAAAAAAAAZDIAACEAAAAAAAAA
AAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAABGAH8AAAAAAAAAAAAAAAAAAAAA
AAAAAABGAH8AAAAAAAAAAAAAAAAAAAAAAAAAAABGAH8AAAAAAAAAAAAAAAAA
AAAAAAAAAABGAH8AAAAAAAAAAAABAAUAAABkAAAAAAABZAAAAAAAAABkAAAA
AAAAAAAAAAAAAAAAAAAAAABkMgAAIQAAAAAAAAAAAAAAAAAAAAAAAAAAAAAA
AAAAAAAAAAAAAEYAfwAAAAAAAAAAAAAAAAAAAAAAAAAAAEYAfwAAAAAAAAAA
AAAAAAAAAAAAAAAAAEYAfwAAAAAAAAAAAAAAAAAAAAAAAAAAAEYAfwAAAAAA
AAAAAAEABQAAAGQAAAAAAAFkAAAAAAAAAGQAAAAAAAAAAAAAAAAAAAAAAAAA
AGQyAAAhAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAARgB/AAAA
AAAAAAAAAAAAAAAAAAAAAAAARgB/AAAAAAAAAAAAAAAAAAAAAAAAAAAARgB/
AAAAAAAAAAAAAAAAAAAAAAAAAAAARgB/AAAAAAAAAAAAAQAFAAAAZAAAAAAA
AWQAAAAAAAAAZAAAAAAAAAAAAAAAAAAAAAAAAAAAZDIAACEAAAAAAAAAAAAA
AAAAAAAAAAAAAAAAAAAAAAAAAAAAAABGAH8AAAAAAAAAAAAAAAAAAAAAAAAA
AABGAH8AAAAAAAAAAAAAAAAAAAAAAAAAAABGAH8AAAAAAAAAAAAAAAAAAAAA
AAAAAABGAH8AAAAAAAAAAAABAAUAAABkAAAAAAABZAAAAAAAAABkAAAAAAAA
AAAAAAAAAAAAAAAAAABkMgAAIQAAAAAAAAAAAAAAAAAAAAAlJCpSKCYuLDAv
LSsxNzM1NkVRUEFCTE04Pj9ASUpHJzQ5Ojs8PUNERkhLTk8jKTJTVFVWV1hZ
WltcXV5fYGFiMDAwMDAwMDAwMDAwMDAwMDAwMDAwMDAwMDAwMDAwMDAwMDAt
AQAFHwQuAgsHCgYJCAwvDiAPEA0YISIjJCUZGhsUFSYnESgeKRwdKhYXKywT
EgMwMTIzNDU2Nzg5Ojs8PT4/MDAwMDAwMDAwMDAwMDAwMDAwMDAwMDAwMDAw
MDAAAwAAiHjOMgB/AGQAZAAAAIh4zjIAfwBkAGRkZAAAAAAAAAAAAAAAAAAA
AA==
EOF

class TestPGM < Test::Unit::TestCase
	def setup
		@pgm_file_content = Base64.decode64(BASE64_ENCODED_PGM_FILE)
	end
	
	def test_unpack_header
		assert_equal(
			{
				:file_size_in_bytes => PGM::VALID_FILE_SIZE_IN_BYTES,
				:filetype_string => PGM::VALID_FILETYPE_STRING,
				:program_play => :poly
			},
			PGM.unpack_header(@pgm_file_content)
 		)
	end
	
	def test_pack_header
		assert_equal(
			@pgm_file_content[0...PGM::HEADER_SIZE],
			PGM.pack_header(:poly)
		)
	end

	def test_unpack_sample
		first_sample_offset = PGM::HEADER_SIZE
		
		assert_equal(
			{
				:sample_name => "808 Kick_long",
				:level => 100,
				:range_lower => 0,
				:range_upper => 127,
				:tuning => 0,
				:play_mode => :one_shot,
				:velocity_to_pitch => 0,
			},
			PGM.unpack_sample(@pgm_file_content[first_sample_offset...first_sample_offset+PGM::SAMPLE_DATA_SIZE])
		)
	end

	def test_pack_sample
		first_sample_offset = PGM::HEADER_SIZE
		
		assert_equal(
			@pgm_file_content[first_sample_offset...first_sample_offset+PGM::SAMPLE_DATA_SIZE],
			PGM.pack_sample(
				{
					:sample_name => "808 Kick_long",
					:level => 100,
					:range_lower => 0,
					:range_upper => 127,
					:tuning => 0,
					:play_mode => :one_shot,
					:velocity_to_pitch => 0,
				}
			)
		)
	end

	def test_unpack_pad
		first_pad_offset = PGM::HEADER_SIZE+(4*PGM::SAMPLE_DATA_SIZE)

		assert_equal(
     {:voice_overlap=>:poly,
      :mute_group=>:off,
      :attack=>0,
      :decay=>5,
      :decay_mode=>:end,
      :velocity_to_attack=>0,
      :velocity_to_start=>0,
      :velocity_to_level=>100,
      :filter1_type=>:lowpass,
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
      :fx_send_level=>36,
      :filter_attenuation=>:zerodb,
      :mute_target1=>:off,
      :mute_target2=>:off,
      :mute_target3=>:off,
      :mute_target4=>:off},
			PGM.unpack_pad(@pgm_file_content[first_pad_offset...first_pad_offset+PGM::PAD_DATA_SIZE])
		)
	end

	def test_pack_pad
		first_pad_offset = PGM::HEADER_SIZE+(4*PGM::SAMPLE_DATA_SIZE)

		assert_equal(
			@pgm_file_content[first_pad_offset...first_pad_offset+PGM::PAD_DATA_SIZE-(4*PGM::SAMPLE_DATA_SIZE)],
			PGM.pack_pad(
	     {:voice_overlap=>:poly,
	      :mute_group=>:off,
	      :attack=>0,
	      :decay=>5,
	      :decay_mode=>:end,
	      :velocity_to_attack=>0,
	      :velocity_to_start=>0,
	      :velocity_to_level=>100,
	      :filter1_type=>:lowpass,
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
	      :fx_send_level=>36,
	      :filter_attenuation=>:zerodb,
 	      :mute_target1=>:off,
 	      :mute_target2=>:off,
 	      :mute_target3=>:off,
 	      :mute_target4=>:off}
			)
		)
	end

	def test_unpack_midi
		assert_equal(
		  {:pad_midi_note_values=>
		    [37,
		     36,
		     42,
		     82,
		     40,
		     38,
		     46,
		     44,
		     48,
		     47,
		     45,
		     43,
		     49,
		     55,
		     51,
		     53,
		     54,
		     69,
		     81,
		     80,
		     65,
		     66,
		     76,
		     77,
		     56,
		     62,
		     63,
		     64,
		     73,
		     74,
		     71,
		     39,
		     52,
		     57,
		     58,
		     59,
		     60,
		     61,
		     67,
		     68,
		     70,
		     72,
		     75,
		     78,
		     79,
		     35,
		     41,
		     50,
		     83,
		     84,
		     85,
		     86,
		     87,
		     88,
		     89,
		     90,
		     91,
		     92,
		     93,
		     94,
		     95,
		     96,
		     97,
		     98],
		   :midi_note_pad_values=>
		    [48,
		     48,
		     48,
		     48,
		     48,
		     48,
		     48,
		     48,
		     48,
		     48,
		     48,
		     48,
		     48,
		     48,
		     48,
		     48,
		     48,
		     48,
		     48,
		     48,
		     48,
		     48,
		     48,
		     48,
		     48,
		     48,
		     48,
		     48,
		     48,
		     48,
		     48,
		     48,
		     48,
		     48,
		     48,
		     45,
		     1,
		     0,
		     5,
		     31,
		     4,
		     46,
		     2,
		     11,
		     7,
		     10,
		     6,
		     9,
		     8,
		     12,
		     47,
		     14,
		     32,
		     15,
		     16,
		     13,
		     24,
		     33,
		     34,
		     35,
		     36,
		     37,
		     25,
		     26,
		     27,
		     20,
		     21,
		     38,
		     39,
		     17,
		     40,
		     30,
		     41,
		     28,
		     29,
		     42,
		     22,
		     23,
		     43,
		     44,
		     19,
		     18,
		     3,
		     48,
		     49,
		     50,
		     51,
		     52,
		     53,
		     54,
		     55,
		     56,
		     57,
		     58,
		     59,
		     60,
		     61,
		     62,
		     63,
		     48,
		     48,
		     48,
		     48,
		     48,
		     48,
		     48,
		     48,
		     48,
		     48,
		     48,
		     48,
		     48,
		     48,
		     48,
		     48,
		     48,
		     48,
		     48,
		     48,
		     48,
		     48,
		     48,
		     48,
		     48,
		     48,
		     48,
		     48,
		     48],
		   :midi_program_change=>:off},
			PGM.unpack_midi(@pgm_file_content[PGM::MIDI_SECTION_OFFSET...PGM::MIDI_SECTION_OFFSET+PGM::MIDI_SECTION_SIZE])
		)
	end

	def test_pack_midi
		assert_equal(
			@pgm_file_content[PGM::MIDI_SECTION_OFFSET...PGM::MIDI_SECTION_OFFSET+PGM::MIDI_SECTION_SIZE],
			PGM.pack_midi(
			  {:pad_midi_note_values=>
			    [37,
			     36,
			     42,
			     82,
			     40,
			     38,
			     46,
			     44,
			     48,
			     47,
			     45,
			     43,
			     49,
			     55,
			     51,
			     53,
			     54,
			     69,
			     81,
			     80,
			     65,
			     66,
			     76,
			     77,
			     56,
			     62,
			     63,
			     64,
			     73,
			     74,
			     71,
			     39,
			     52,
			     57,
			     58,
			     59,
			     60,
			     61,
			     67,
			     68,
			     70,
			     72,
			     75,
			     78,
			     79,
			     35,
			     41,
			     50,
			     83,
			     84,
			     85,
			     86,
			     87,
			     88,
			     89,
			     90,
			     91,
			     92,
			     93,
			     94,
			     95,
			     96,
			     97,
			     98],
			   :midi_note_pad_values=>
			    [48,
			     48,
			     48,
			     48,
			     48,
			     48,
			     48,
			     48,
			     48,
			     48,
			     48,
			     48,
			     48,
			     48,
			     48,
			     48,
			     48,
			     48,
			     48,
			     48,
			     48,
			     48,
			     48,
			     48,
			     48,
			     48,
			     48,
			     48,
			     48,
			     48,
			     48,
			     48,
			     48,
			     48,
			     48,
			     45,
			     1,
			     0,
			     5,
			     31,
			     4,
			     46,
			     2,
			     11,
			     7,
			     10,
			     6,
			     9,
			     8,
			     12,
			     47,
			     14,
			     32,
			     15,
			     16,
			     13,
			     24,
			     33,
			     34,
			     35,
			     36,
			     37,
			     25,
			     26,
			     27,
			     20,
			     21,
			     38,
			     39,
			     17,
			     40,
			     30,
			     41,
			     28,
			     29,
			     42,
			     22,
			     23,
			     43,
			     44,
			     19,
			     18,
			     3,
			     48,
			     49,
			     50,
			     51,
			     52,
			     53,
			     54,
			     55,
			     56,
			     57,
			     58,
			     59,
			     60,
			     61,
			     62,
			     63,
			     48,
			     48,
			     48,
			     48,
			     48,
			     48,
			     48,
			     48,
			     48,
			     48,
			     48,
			     48,
			     48,
			     48,
			     48,
			     48,
			     48,
			     48,
			     48,
			     48,
			     48,
			     48,
			     48,
			     48,
			     48,
			     48,
			     48,
			     48,
			     48],
			   :midi_program_change=>:off}
			)
		)
	end

	def test_unpack_slider
		assert_equal(
	   {:pad=>2,
	    :change=>:real_time,
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
	    :decay_high=>100},
			PGM.unpack_slider(@pgm_file_content[PGM::SLIDERS_SECTION_OFFSET...PGM::SLIDERS_SECTION_OFFSET+PGM::SLIDER_DATA_SIZE])
		)
	end

	def test_pack_slider
		assert_equal(
			@pgm_file_content[PGM::SLIDERS_SECTION_OFFSET...PGM::SLIDERS_SECTION_OFFSET+PGM::SLIDER_DATA_SIZE],
			PGM.pack_slider(
		   {:pad=>2,
		    :change=>:real_time,
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
		    :decay_high=>100}
			)
		)
	end

	def test_unpack_slider_extra
		assert_equal(
	   {:slider_level_low=>100,
	    :slider_level_high=>100},
			PGM.unpack_slider_extra(@pgm_file_content[PGM::SLIDERS_SECTION_OFFSET+2*PGM::SLIDER_DATA_SIZE...PGM::SLIDERS_SECTION_OFFSET+2*PGM::SLIDER_DATA_SIZE+2])
		)
	end

	def test_pack_slider_extra
		assert_equal(
			@pgm_file_content[PGM::SLIDERS_SECTION_OFFSET+2*PGM::SLIDER_DATA_SIZE...PGM::SLIDERS_SECTION_OFFSET+2*PGM::SLIDER_DATA_SIZE+2],
			PGM.pack_slider_extra(
	     {:slider_level_low=>100,
	      :slider_level_high=>100}
			)
		)
	end

	def test_pack_default_program
		assert_nothing_raised do
			PGM.pack_pgm(PGM::Defaults::PROGRAM)
		end
	end

	def test_pack_unpack_default_program
		assert_equal(
			PGM::Defaults::PROGRAM,
			PGM.unpack_pgm(PGM.pack_pgm(PGM::Defaults::PROGRAM))
		)
	end
end
