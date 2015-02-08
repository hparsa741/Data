using Distributions
using Gadfly
using DataFrames

# Single game function with an uncertain outcome considering a house edge of 1.5 percent
function rollDice()
    rnd = rand(1:1000)
    if rnd < 516
        return false
    else
        return true
    end
end

# Wagering function of variable wager multiplier until wager count or all funds lost
function Martingale(multiplier, funds, initialWager, count)
    global bustsCount
    global profitsCount
    counter = 1
    wager = initialWager
    value = funds
    prevWager = "win"
    while counter <= count
        if prevWager == "win"
            wager = initialWager
            if rollDice()
                value += wager
                prevWager = "win"
            else
                value -= wager
                prevWager = "loss"
                if value <= 0
                    bustsCount += 1
                    break
                end
            end
        elseif prevWager == "loss"
            wager *= multiplier
            if (value - wager) < 0
                wager = value
            end
            if rollDice()
                value += wager
                prevWager = "win"
            else
                value -= wager
                prevWager = "loss"
                if value <= 0
                    bustsCount += 1
                    break
                end
            end
        end
        counter += 1
    end
    if value > funds
        profitsCount += 1
    end
end

# Wagering function of constant wager multiplier until wager count or all funds lost
function bettor(funds=20000, initialWager=100, count=1000)
    counter = 1
    wager = initialWager
    value = funds
    prevWager = "win"
    while counter <= count
        if prevWager == "win"
            wager = initialWager
            if rollDice()
                value += wager
                prevWager = "win"
                push!(fundsArr, value)
            else
                value -= wager
                prevWager = "loss"
                push!(fundsArr, value)
                if value <= 0
                    break
                end
            end
        elseif prevWager == "loss"
            wager *= multiplier
            if (value - wager) < 0
                wager = value
            end
            if rollDice()
                value += wager
                prevWager = "win"
                push!(fundsArr, value)
            else
                value -= wager
                prevWager = "loss"
                push!(fundsArr, value)
                if value <= 0
                    break
                end
            end
        end
        counter += 1
    end
    println("Total Wager Count: ", counter)
    println("Initial Funds: ", funds)
    println("Terminal Value: ", value)
    global mdf=DataFrame(A=[1:length(fundsArr)], B=[fundsArr])
end

# multiplier = 1
srand(10)
global fundsArr = Float64[]
global multiplier = 1

bettor()

plot(layer(yintercept=[mdf[end,:B]], Geom.hline(color="brown", size=.5mm)),
layer(yintercept=[mdf[1,:B]], Geom.hline(color="orange", size=.5mm)),
layer(x=mdf[:A], y=mdf[:B], Geom.line),
Guide.xlabel("Wager Count"), Guide.ylabel("Value", orientation=:vertical),
Theme(line_width=.5mm, default_color=color("darkgreen")))

# multiplier = 1.5
srand(10)
global fundsArr = Float64[]
global multiplier = 1.5

bettor()

plot(layer(yintercept=[mdf[end,:B]], Geom.hline(color="brown", size=.5mm)),
layer(yintercept=[mdf[1,:B]], Geom.hline(color="orange", size=.5mm)),
layer(x=mdf[:A], y=mdf[:B], Geom.line),
Guide.xlabel("Wager Count"), Guide.ylabel("Value", orientation=:vertical),
Theme(line_width=.5mm, default_color=color("darkgreen")))

# multiplier = 2
srand(10)
global fundsArr = Float64[]
global multiplier = 2

bettor()

plot(layer(yintercept=[mdf[end,:B]], Geom.hline(color="brown", size=.5mm)),
layer(yintercept=[mdf[1,:B]], Geom.hline(color="orange", size=.5mm)),
layer(x=mdf[:A], y=mdf[:B], Geom.line),
Guide.xlabel("Wager Count"), Guide.ylabel("Value", orientation=:vertical),
Theme(line_width=.5mm, default_color=color("darkgreen")))

# Risk-return trade off
global profArr = Float64[]
global bustArr = Float64[]
global multArr = Float64[]
srand(10)
for mult = 1:0.05:2.5 # trying a range of wager multiplier from 1 to 2.5 with step of 0.05
    bustsCount = 0
    profitsCount = 0
    sampleSize = 10000
    currentCount = 1
    while currentCount <= sampleSize
        Martingale(mult, 10000, 100, 200)
        currentCount += 1
    end
    push!(multArr, mult)
    push!(profArr, 100*profitsCount/sampleSize) # Average number of samples where bettor gained profit
    push!(bustArr, 100*bustsCount/sampleSize) # Average number of samples where bettor lost his funds
end


bustDf=DataFrame(A=[multArr], B=[bustArr], Metric="Broke")
profDf=DataFrame(A=[multArr], B=[profArr], Metric="Profit")
df= vcat(bustDf, profDf)

minProf = 50 # min Return set by bettor
maxBust = 25 # max Risk set by bettor

plot(layer(xintercept=[minimum(profDf[profDf[:B] .>= minProf, :A]), maximum(profDf[profDf[:B] .>= minProf, :A])],
            Geom.vline(color="orange", size=.1mm)),
    layer(xintercept=[profDf[profDf[:B] .== maximum(profDf[:B]), :A]], Geom.vline(color="cyan", size=.1mm)),
    layer(yintercept=[minimum(profDf[profDf[:B] .>= minProf, :B]), maximum(bustDf[bustDf[:B] .<= maxBust, :B])],
            Geom.hline(color="orange", size=.1mm)),
    layer(xintercept=[maximum(bustDf[bustDf[:B] .<= maxBust, :A])], Geom.vline(color="magenta", size=.1mm)),
    layer(df, x=df[:A], y=df[:B], color="Metric", Geom.line, Theme(line_width=.8mm)),
Guide.xlabel("Multiplier"),
Guide.ylabel("Rate %", orientation=:vertical),
Scale.discrete_color_manual("brown","darkgreen"))