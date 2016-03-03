
  module Color
    OFF = 12
    FLASH_MODIFIER = -4
    RED = 15
    RED_FLASH = RED + FLASH_MODIFIER
    GREEN = 60
    GREEN_FLASH = GREEN + FLASH_MODIFIER
    YELLOW = 62
    YELLOW_FLASH = YELLOW + FLASH_MODIFIER
    AMBER = 63
    AMBER_FLASH = AMBER + FLASH_MODIFIER
  end

  module Note
    C0 = 0
    D0 = 2
    E0 = 4
    F0 = 5
    G0 = 7
    A0 = 9
    B0 = 11
    C1 = 12
    C2 = 24
    C3 = 36
    C4 = 48
    C5 = 60
    C6 = 72
    C7 = 82
    C8 = 94
    C9 = 106
    C10 = 118
  end

  module Scale
    CHROMATIC = [0, 1, 2, 3, 4, 5, 6, 7, 8, 9, 10, 12]
    MAJOR = [0, 2, 4, 5, 7, 9, 11, 12]
    NATURAL_MINOR = [0, 2, 3, 5, 7, 8, 10, 12]
    MELODIC_MINOR = [0, 2, 3, 5, 7, 9, 11, 12]
    HARMONIC_MINOR = [0, 2, 3, 5, 7, 8, 11, 12]

    TABLE = { "Chromatic" => CHROMATIC, "Major" => MAJOR, "Natural-Minor" => NATURAL_MINOR, "Melodic-Minor" => MELODIC_MINOR, "Harmonic-Minor" => HARMONIC_MINOR }
  end
