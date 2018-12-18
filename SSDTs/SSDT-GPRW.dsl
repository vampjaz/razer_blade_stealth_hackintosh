DefinitionBlock("", "SSDT", 2, "JAZZY", "gprw-usb", 0)
{
    External (PRWP, IntObj)
    External (SS1, IntObj)
    External (SS2, IntObj)
    External (SS3, IntObj)
    External (SS4, IntObj)
    
    Scope (\)
    {
        Method (GPRW, 2, NotSerialized)
        {
            Store (Arg0, Index (PRWP, Zero))
            Store (ShiftLeft (SS1, One), Local0)
            Or (Local0, ShiftLeft (SS2, 0x02), Local0)
            Or (Local0, ShiftLeft (SS3, 0x03), Local0)
            Or (Local0, ShiftLeft (SS4, 0x04), Local0)
            If (And (ShiftLeft (One, Arg1), Local0))
            {
                Store (Arg1, Index (PRWP, One))
            }
            Else
            {
                ShiftRight (Local0, One, Local0)
                FindSetLeftBit (Local0, Index (PRWP, One))
            }

            If (LEqual (Arg0, 0x6D))
            {
                Store (Zero, Index (PRWP, One))
            }

            Return (PRWP)
        }
    }
}