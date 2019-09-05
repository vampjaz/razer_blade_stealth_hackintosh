DefinitionBlock("", "SSDT", 2, "JAZZY", "unglan", 0)
{
    External (\_SB.PCI0.GLAN, DeviceObj)

    Scope (\)
    {
        Scope (_SB.PCI0.GLAN)
        {
            Method (_STA, 0, NotSerialized)
            {
                Return (Zero)
            }
        }
    }
}