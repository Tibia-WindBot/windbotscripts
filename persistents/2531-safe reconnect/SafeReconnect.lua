init start
    -- local SCRIPT_VERSION = "3.0.0"

    local ignoreServerSavingTime = false
    local reopenVisibleBackpacks = true

    local accountsInformation    = {
        {
            accountName = "accountName",
            accountPassword = "accountpassword",
            characters = {"Bubble", "Eternal Oblivion"}
        },
        {
            accountName = "accountName2",
            accountPassword = "accountpassword2",
            characters = {"Lord\'Paulistinha", "Crisne"}
        },
    }

    local specialChecks = {
        {
            function()
                return isontemple()
            end,
            function()
                printerrorf("AutoReconnect: [%q] Client closed. Reason: Character was inside a temple.", $name)
                closeclient(true)
            end
        },
        {
            function()
                return ($self.skull == SKULL_RED or $self.skull == SKULL_BLACK) and $pzone
            end,
            function()
                printerrorf("AutoReconnect: [%q] Client closed. Reason: Character was red/black skulled inside a protection zone.", $name)
                closeclient(true)
            end
        },
        {
            function()
                return $stamina <= 840 and $pzone
            end,
            function()
                printerrorf("AutoReconnect: [%q] Client closed. Reason: Character had less/equal than 14 hours of stamina and inside a protection zone.", $name)
                closeclient(true)
            end
        },
    }

    -- DO NOT EDIT BELOW --
    if autoReconnecter == nil then
        autoReconnecter = {
            enabled = true
        }

        autoReconnecter.isEnabled = function()
            return autoReconnecter.enabled
        end

        autoReconnecter.pause = function()
            autoReconnecter.enabled = false
        end

        autoReconnecter.resume = function()
            autoReconnecter.enabled = true
        end
    end

    for _, accountEntry in pairs(accountsInformation) do
        table.lower(accountEntry.characters)
    end

    local randTimeSS = math.random(100, 700)

init end

auto(1000, 2000)

local currentServerSaveTime = sstime()

if autoReconnecter.enabled and (not $connected) and (ignoreServerSavingTime or (currentServerSaveTime >= 600 + randTimeSS and currentServerSaveTime <= 85800 - randTimeSS)) then
    if $name ~= "" then
        local index = 0

        for i, accountEntry in pairs(accountsInformation) do
            if table.find(accountEntry.characters, $name:lower()) then
                index = i
                break
            end
        end

        if index > 0 then
            local login = accountsInformation[index]
            local oldTypeTimeSettings = get('Settings/TypeWaitTime')
            local oldPressTimeSettings = get('Settings/PressWaitTime')

            set('Settings/TypeWaitTime', '110 x 140')
            set('Settings/PressWaitTime', '100 x 250')
            setlifetime(20000)

            while (not $connected) do
                connect(login.accountName, login.accountPassword, $name) wait(200)
            end

            set('Settings/TypeWaitTime', oldTypeTimeSettings)
            set('Settings/PressWaitTime', oldPressTimeSettings)

            for _, checkCallback in pairs(specialChecks) do
                if checkCallback[1]() then
                    checkCallback[2]()
                end
            end

            if reopenVisibleBackpacks then
                local oldOpenNextBpSettings = get('Looting/OpenNextBP')
                local oldFocusPolicySettings = get('Settings/FocusPolicy')
                local oldOpenBpsAtLoginSettings = get('Looting/OpenBPsAtLogin')
                
                set('Looting/OpenBPsAtLogin', 'no')
                set('Settings/FocusPolicy', 'Focus on any event')
                set('Looting/OpenNextBP', 'no')
                setlifetime(10000)
                reopenwindows('small')

                while $openingbps do
                    wait(500) pausewalking(500)
                end

                pausewalking(0)
                set('Looting/OpenNextBP', oldOpenNextBpSettings)
                set('Settings/FocusPolicy', oldFocusPolicySettings)
                set('Looting/OpenBPsAtLogin', oldOpenBpsAtLoginSettings)
            end
        else
            printerrorf("AutoReconnect: Account details for %q doesn't exist.", $name)
        end
    else
        printerrorf("AutoReconnect: Please login first to save your credentials.")
    end
end
