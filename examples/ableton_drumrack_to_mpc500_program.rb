require 'nokogiri'
require 'zlib'
require 'fileutils'
require 'securerandom'

require "../lib/pgm"

if drumrack_adg = ARGV[0]
  doc = Zlib::GzipReader.open(drumrack_adg) do |gz|
    Nokogiri::XML(gz.read)
  end

  drumrack = doc.xpath("/Ableton/GroupDevicePreset/BranchPresets/DrumBranchPreset").each_with_index.map do |drum_branch_preset, index|
    {
      :name => doc.at_xpath("//Ableton/GroupDevicePreset/BranchPresets/DrumBranchPreset[@Id=#{index}]/DevicePresets/AbletonDevicePreset[@Id=0]/Device/OriginalSimpler[@Id=0]/Player/MultiSampleMap/SampleParts/MultiSamplePart[@Id=0]/Name").attributes["Value"].value,
      :path => doc.at_xpath("//Ableton/GroupDevicePreset/BranchPresets/DrumBranchPreset[@Id=#{index}]/DevicePresets/AbletonDevicePreset[@Id=0]/Device/OriginalSimpler[@Id=0]/Player/MultiSampleMap/SampleParts/MultiSamplePart[@Id=0]/SampleRef/FileRef/Path").attributes["Value"].value,
      :receiving_note => 128 - doc.at_xpath("//Ableton/GroupDevicePreset/BranchPresets/DrumBranchPreset[@Id=#{index}]/ZoneSettings/ReceivingNote").attributes["Value"].value.to_i,
      :sending_note => doc.at_xpath("//Ableton/GroupDevicePreset/BranchPresets/DrumBranchPreset[@Id=#{index}]/ZoneSettings/SendingNote").attributes["Value"].value.to_i,
      :choke_group => doc.at_xpath("//Ableton/GroupDevicePreset/BranchPresets/DrumBranchPreset[@Id=#{index}]/ZoneSettings/ChokeGroup").attributes["Value"].value,
    }
  end

  program_name = "Prog_#{SecureRandom.uuid[0...3]}"
  program_folder = "./#{program_name}"
  FileUtils.mkdir_p(program_folder)

  MPC500_BANKS = [
    [
      [ 49, 55, 51 ],
      [ 48, 47, 45 ],
      [ 40, 38, 46 ],
      [ 37, 36, 42 ]
    ],
    [
      [ 73, 74, 71 ],
      [ 56, 62, 63 ],
      [ 65, 66, 76 ],
      [ 54, 69, 81 ]
    ],
    [
      [ 79, 35, 41 ],
      [ 70, 72, 75 ],
      [ 60, 61, 67 ],
      [ 52, 57, 58 ]
    ],
    [
      [ 95, 96, 97 ],
      [ 91, 92, 93 ],
      [ 87, 88, 89 ],
      [ 83, 84, 85 ]
    ]
  ]

  def lookup_pad_index(mpc500_banks, midinote)
    pad_notes = mpc500_banks.map do |bank|
      bank.reverse
    end.flatten
    pad_notes.index(midinote)
  end

  def lookup_bank_pad_index(bank, midinote)
    row1_index = bank[3].index(midinote)
    return row1_index if row1_index

    row2_index = bank[2].index(midinote)
    return 3 + row2_index if row2_index

    row3_index = bank[1].index(midinote)
    return 3 + 3 + row3_index if row3_index

    row4_index = bank[0].index(midinote)
    return 3 + 3 + 3 + row4_index if row4_index
  end

  def lookup_pad_name(mpc500_banks, midinote)
    bank_a = mpc500_banks[0]
    pad_index = lookup_bank_pad_index(bank_a, midinote)
    return "A#{pad_index+1}" if pad_index

    bank_b = mpc500_banks[1]
    pad_index = lookup_bank_pad_index(bank_b, midinote)
    return "B#{pad_index+1}" if pad_index

    bank_c = mpc500_banks[2]
    pad_index = lookup_bank_pad_index(bank_c, midinote)
    return "C#{pad_index+1}" if pad_index

    bank_d = mpc500_banks[3]
    pad_index = lookup_bank_pad_index(bank_d, midinote)
    return "D#{pad_index+1}" if pad_index
  end

  selected_drumrack_pads = MPC500_BANKS.flatten.map do |program_note| # TODO: remove reverse, not required
    drumrack_pad_settings = drumrack.detect do |drumrack_pad_settings|
      drumrack_pad_settings[:receiving_note] == program_note
    end
    if drumrack_pad_settings
      drumrack_pad_settings
    end
  end.reject { |drumrack_pad_settings| drumrack_pad_settings == nil }

  program = PGM::Defaults::PROGRAM.dup

  selected_drumrack_pads.each_with_index.map do |drumrack_pad_settings, index|
    sample_path = drumrack_pad_settings[:path]
    program_note = drumrack_pad_settings[:receiving_note]
    pad_name = lookup_pad_name(MPC500_BANKS, program_note)
    sample_basename = File.basename(sample_path)
    raise "pad #{pad_name} (#{program_note}), path #{sample_path}: only wav files allowed" if File.extname(sample_path) != ".wav"
    # TODO raise "only 16 bit wav samples allowed" check
    sample_name_without_wav_extension = File.basename(sample_path, ".wav")
    sample_name = "#{sample_name_without_wav_extension[0..15]}.wav"
    puts "#{pad_name} (#{program_note}): #{drumrack_pad_settings[:path]} => #{program_folder}/#{sample_name}"
    FileUtils.cp(drumrack_pad_settings[:path], "#{program_folder}/#{sample_name}")
    mpc_sample_name = File.basename(sample_name, ".wav")

    selected_drumrack_pad = {
      :pad_index => lookup_pad_index(MPC500_BANKS, program_note),
      :midinote => program_note,
      :name => drumrack_pad_settings[:name],
      :path => drumrack_pad_settings[:path],
      :mpc_sample_name => mpc_sample_name
    }
    selected_drumrack_pad 
    # TODO: check uniqueness of sample names
  end.each do |pad|
    pad_index = pad[:pad_index]
    midinote = pad[:midinote]
    sample_name = pad[:mpc_sample_name]

    program[:pads][pad_index][:samples][0][:sample_name] = sample_name
    program[:midi][:pad_midi_note_values][pad_index] = midinote
  end

  puts "new program => #{program_folder}/#{program_name}.PGM"

  PGM.write_file("#{program_folder}/#{program_name}.PGM", program)
else
  puts "usage: ruby #{File.basename(__FILE__)} [ableton-drumrack-preset.adg]"
end
