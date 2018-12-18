DefinitionBlock("", "SSDT", 2, "JAZZY", "batt", 0)
{
    External (\_SB.PCI0.LPCB.EC, DeviceObj)
    External (\_SB.PCI0.LPCB.EC.ECON, IntObj)
    External (\_SB.PCI0.LPCB.EC.PSTA, IntObj)
    External (\_SB.PCI0.LPCB.BAT0, DeviceObj)
    External (\_SB.PCI0.LPCB.BAT0.PAK1, IntObj)
    External (\_SB.PCI0.LPCB.BAT0.PAK2, IntObj)
    External (\_SB.PCI0.LPCB.BAT0.BFB0, IntObj)
    External (\_SB.PCI0.LPCB.BAT0.BFB1, IntObj)

    Scope (\)
    {
        Scope (_SB.PCI0.LPCB.EC)
        {
            OperationRegion (JAZ1, EmbeddedControl, Zero, 0xFF)
            Field (JAZ1, ByteAcc, NoLock, Preserve)
            {
                Offset (0x60), 
                ECCX,256, 
                Offset (0x90), 
                IF00,8,IF01,8, 
                IF10,8,IF11,8, 
                IF20,8,IF21,8, 
                IF30,8,IF31,8, 
                IF40,8,IF41,8, 
                Offset (0xA2),
                ST00,8,ST01,8, 
                ST10,8,ST11,8, 
                ST20,8,ST21,8, 
                ST30,8,ST31,8
            }

            Method (RE1B, 1, NotSerialized)
            {
                OperationRegion(ERAM, EmbeddedControl, Arg0, 1)
                Field(ERAM, ByteAcc, NoLock, Preserve) { BYTE, 8 }
                Return(BYTE)
            }

            Method (RECB, 2, Serialized)
            {
                ShiftRight(Add(Arg1,7), 3, Arg1)
                Name(TEMP, Buffer(Arg1) { })
                Add(Arg0, Arg1, Arg1)
                Store(0, Local0)
                While (LLess(Arg0, Arg1))
                {
                    Store(RE1B(Arg0), Index(TEMP, Local0))
                    Increment(Arg0)
                    Increment(Local0)
                }
                Return(TEMP)
            }
        }

        Scope (_SB.PCI0.LPCB.BAT0)
        {
            Method (_BIF, 0, NotSerialized)  // _BIF: Battery Information
            {
                Store (ToString (\_SB.PCI0.LPCB.EC.RECB(0x60,256), 0x20), Index (PAK1, 0x0A))
                Store (ToString (\_SB.PCI0.LPCB.EC.RECB(0x60,256), 0x20), Index (PAK2, 0x0A))
                If (LEqual (\_SB.PCI0.LPCB.EC.ECON, One))
                {
                    Store (B1B2(\_SB.PCI0.LPCB.EC.IF10,\_SB.PCI0.LPCB.EC.IF11), Index (PAK1, One))
                    Store (B1B2(\_SB.PCI0.LPCB.EC.IF20,\_SB.PCI0.LPCB.EC.IF21), Index (PAK1, 0x02))
                    Store (B1B2(\_SB.PCI0.LPCB.EC.IF30,\_SB.PCI0.LPCB.EC.IF31), Index (PAK1, 0x03))
                    Store (B1B2(\_SB.PCI0.LPCB.EC.IF40,\_SB.PCI0.LPCB.EC.IF41), Index (PAK1, 0x04))
                    Store (Divide (B1B2(\_SB.PCI0.LPCB.EC.IF10,\_SB.PCI0.LPCB.EC.IF11), 0x32, ), Index (PAK1, 0x05))
                    Store (Divide (B1B2(\_SB.PCI0.LPCB.EC.IF10,\_SB.PCI0.LPCB.EC.IF11), 0x64, ), Index (PAK1, 0x06))
                    Store (\_SB.PCI0.LPCB.EC.PSTA, Local0)
                    And (Local0, 0x83, Local0)
                    If (LEqual (Local0, 0x82))
                    {
                        Return (PAK1)
                    }

                    If (LEqual (Local0, 0x83))
                    {
                        Return (PAK1)
                    }

                    If (LEqual (Local0, 0x81))
                    {
                        Return (PAK2)
                    }

                    Return (PAK2)
                }
                Else
                {
                    Return (PAK2)
                }

                Return (PAK2)
            }

            Method (_BST, 0, NotSerialized)  // _BST: Battery Status
            {
                If (LEqual (\_SB.PCI0.LPCB.EC.ECON, One))
                {
                    Store (B1B2(\_SB.PCI0.LPCB.EC.ST00,\_SB.PCI0.LPCB.EC.ST01), Index (BFB0, Zero))
                    Store (B1B2(\_SB.PCI0.LPCB.EC.ST10,\_SB.PCI0.LPCB.EC.ST11), Index (BFB0, One))
                    Store (B1B2(\_SB.PCI0.LPCB.EC.ST20,\_SB.PCI0.LPCB.EC.ST21), Index (BFB0, 0x02))
                    Store (B1B2(\_SB.PCI0.LPCB.EC.ST30,\_SB.PCI0.LPCB.EC.ST31), Index (BFB0, 0x03))
                    Store (\_SB.PCI0.LPCB.EC.PSTA, Local0)
                    And (Local0, 0x83, Local0)
                    If (LEqual (Local0, 0x82))
                    {
                        Return (BFB0)
                    }

                    If (LEqual (Local0, 0x83))
                    {
                        Return (BFB0)
                    }

                    If (LEqual (Local0, 0x81))
                    {
                        Return (BFB1)
                    }

                    Return (BFB1)
                }
                Else
                {
                    Return (BFB1)
                }
            }
        }
        Method (B1B2, 2, NotSerialized) 
        { 
            Return (Or (Arg0, ShiftLeft (Arg1, 8))) 
        }
    }
}