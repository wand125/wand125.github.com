class Status
  constructor: ->
    @gold = null
    @totalGold = null
    @tax = null
    @growth = null
    @slimes = null
    @lastSlimeText = ''
    @bestNRed = null
    @bestNYellow = null
    @bestNGreen = null
    @bestNBlue = null
    @bestSize = null
    @medals = null

  sortSlime: ->
    @slimes.sort((a,b)->
      if(a.rank != b.rank)
        b.rank - a.rank
      else if(a.color != b.color)
        a.color - b.color
      else
        a.size - b.size
    )

class Game
  status = null
  composeId = -1
  frameCount = 0
  beforeTime = -1

  debug : (gold)->
    status.slimes = []
    status.gold = gold
    status.totalGold = gold
    status.growth = 0
    status.tax = 0
    status.medal = []
    @setSlimesElement()
    @setGrowthElement()

  reset: ->
    status.slimes = []
    status.gold = 0
    status.totalGold = 0
    status.growth = 0
    status.tax = 0
    save()
    @setSlimesElement()
    @setGrowthElement()

  init : ->
    load()
    @setSlimesElement()
    @setGrowthElement()
    setInterval(update, 100)

  load = ->
    status = new Status()
    status.gold = parseInt(localStorage.getItem('gold'))
    status.gold = 0 if !status.gold
    
    status.totalGold = parseInt(localStorage.getItem('totalGold'))
    status.totalGold = 0 if !status.totalGold
    status.totalGold = status.gold if status.gold > status.totalGold

    saveTime = parseInt(localStorage.getItem('time'))
    if saveTime
      date = new Date()
      loadTime = date.getTime()
      status.gold += Math.floor((date.getTime() - saveTime) / 1000)
      status.totalGold += Math.floor((date.getTime() - saveTime) / 1000)

    status.tax = parseInt(localStorage.getItem('tax'))
    status.tax = 0 if !status.tax

    status.growth = parseInt(localStorage.getItem('growth'))
    status.growth = 0 if !status.growth

    slimeData = localStorage.getItem('slimes')
    if slimeData and slimeData isnt 'undefined' and slimeData isnt 'null'
      console.log slimeData
      status.slimes = JSON.parse(slimeData)
    else
      status.slimes = []

    slimeMedals = localStorage.getItem('medals')
    if slimeMedals and slimeMedals isnt 'undefined' and slimeMedals isnt 'null'
      console.log slimeMedals
      status.medals = JSON.parse(slimeMedals)
    else
      status.medals = [0,0,0,0]

    status.lastSlimeText = localStorage.getItem('lastSlimeText')
    status.lastSlimeText = '' if status.lastSlimeText is 'null' or status.lastSlimeText is null
    console.log("load Gold is #{status.gold}")
    console.log("load TotalGold is #{status.totalGold}")

    status.bestNRed = localStorage.getItem('bestNRed')
    status.bestNRed = 0 if !status.bestNRed

    status.bestNYellow = localStorage.getItem('bestNYellow')
    status.bestNYellow = 0 if !status.bestNYellow

    status.bestNGreen = localStorage.getItem('bestNGreen')
    status.bestNGreen = 0 if !status.bestNGreen

    status.bestNBlue = localStorage.getItem('bestNBlue')
    status.bestNBlue = 0 if !status.bestNBlue

  save = ->
    localStorage.setItem('gold', status.gold)
    localStorage.setItem('totalGold', status.totalGold)
    localStorage.setItem('tax', status.tax)
    localStorage.setItem('growth', status.growth)
    date = new Date()
    localStorage.setItem('time', date.getTime())
    localStorage.setItem('lastSlimeText', status.lastSlimeText)
    localStorage.setItem('bestNRed', status.bestNRed)
    localStorage.setItem('bestNYellow', status.bestNYellow)
    localStorage.setItem('bestNGreen', status.bestNGreen)
    localStorage.setItem('bestNBlue', status.bestNBlue)
    localStorage.setItem('redMedal', status.redMedal)
    localStorage.setItem('yellowMedal', status.yellowMedal)
    localStorage.setItem('breenMedal', status.greenMedal)
    localStorage.setItem('blueMedal', status.blueMedal)
    localStorage.setItem('medals', JSON.stringify(status.medals))

  update = ->
    ++frameCount
    date = new Date()
    nowTime = date.getTime()
    if beforeTime is -1
      add = 0.1
      beforeTime = nowTime
    else
      add = (nowTime - beforeTime) / 1000
      beforeTime = nowTime
    status.gold += add
    status.totalGold += add

    if frameCount % 10 is 0
      save()
    
    elementGold = document.getElementById('gold')
    elementGold.innerText = "Gold: #{(Math.floor(status.gold))}G"

    elementTotalGold = document.getElementById('total-gold')
    elementTotalGold.innerText = "TotalGold: #{(Math.floor(status.totalGold))}G"

    medalSum = 0
    for medal in status.medals
      medalSum += medal
    elementMedal = document.getElementById('medal')
    elementMedal.innerText = if medalSum > 0 then "Slime Medal: #{medalSum}" else ''

    elementGrowth = document.getElementById('growth')
    elementGrowth.innerText = "Growth: #{Math.floor(status.growth)}"

  setGrowthElement : ->
    elementStore = document.getElementById('store')
    elementStoreHTML = "<ul>"
    
    if status.growth >= 10
      elementStoreHTML += '<li><input type="button" value="スライムショップ(300G)" onclick="game.getSlime()">'
      elementStoreHTML += '--> '+status.lastSlimeText if status.lastSlimeText != ''
      elementStoreHTML += '</li>'
      appearSlimeStore = true
    else
      elementStoreHTML += '<li>Growth:10 -> Open</li>'

    if status.growth >= 20
      elementStoreHTML += '<li>スライム合成所</li>'
      appearSlimeStore = true
    else
      elementStoreHTML += '<li>Growth:20 -> Open</li>'

    if status.growth >= 500
      n = Math.min(Math.floor(status.gold / 300), @getMaxSlimes() - status.slimes.length)
      elementStoreHTML += '<li><input type="button" value="スライムショップ'+"x#{n} (#{300 * n}G)"+'" onclick="game.getSlimes('+n+')">'
      elementStoreHTML += '</li>'
      appearSlimeStore = true
    else
      elementStoreHTML += '<li>Growth:500 -> Open</li>'

    if status.growth >= 1000
      elementStoreHTML += '<li>メダル交換所 [Normal 1000mm -> Medal]</li>'
    else
      elementStoreHTML += '<li>Growth:1000 -> Open</li>'

    if status.growth >= 2000
      elementStoreHTML += '<li><input type="button" value="自動合成(サイズが同じもの)" onclick="game.autoComposeEquals()"></li>'
    else
      elementStoreHTML += '<li>Growth: 4000 -> Open</li>'

    if status.growth >= 4000
      elementStoreHTML += '<li><input type="button" value="自動合成(サイズ比が5%未満のもの)" onclick="game.autoComposeNearby(5)"></li>'
    else
      elementStoreHTML += '<li>Growth: 4000 -> Open</li>'

    if status.growth >= 5000
      elementStoreHTML += '<li><input type="button" value="自動合成(サイズ比が10%未満のもの)" onclick="game.autoComposeNearby(10)"></li>'
    else
      elementStoreHTML += '<li>Growth: 5000 -> Open</li>'

    elementStoreHTML += "</ul>"
    elementStore.innerHTML = elementStoreHTML

  getSlimeText : (slime) ->
    color =
      switch slime.color
        when 0 then 'Red'
        when 1 then 'Yellow'
        when 2 then 'Green'
        when 3 then 'Blue'
    rank =
      switch slime.rank
        when 0 then 'Normal'
        when 1 then 'Fine'
        when 2 then 'Premium'
    "#{rank} #{color} #{slime.size}mm"

  setBestSlime : ->
    for slime in status.slimes
      switch slime.color
        when 0
          status.bestNRed = Math.max(status.bestNRed,slime.size)
        when 1
          status.bestNYellow = Math.max(status.bestNYellow,slime.size)
        when 2
          status.bestNGreen = Math.max(status.bestNGreen,slime.size)
        when 3
          status.bestNBlue = Math.max(status.bestNBlue,slime.size)
    status.bestSize = status.bestNRed + status.bestNYellow + status.bestNGreen + status.bestNBlue

  saveSlime = ->
    localStorage.setItem('slimes', JSON.stringify(status.slimes))

  setSlimesElement : ->
    saveSlime()
    @setBestSlime()

    document.getElementById('best-slime').innerText = 'Best Slime Size Avg. : ' + status.bestSize / 4 + 'mm'

    if status.slimes.length > 0 and status.growth >= 10
      elementSlime = document.getElementById('my-slime')
      slimeHTML = """
      <h2>Slimes</h2>
        <form name='slimeButton' action='#'>
        <p>#{status.slimes.length} / #{@getMaxSlimes()}</p>
        <table>
      """

      composeSlime = status.slimes[composeId] unless composeId is -1

      for slime,index in status.slimes
        slimeHTML += '<tr>'
        slimeHTML += '<td>'+@getSlimeText(slime)+'</td>'
        if status.growth >= 20
          slimeHTML += '<td>'
          if composeId is -1
            if status.slimes[index].size < 1000
              slimeHTML += "<input type='button' value='合成' onclick='game.compose(#{index})'>"
            else if status.growth >= 1000
              slimeHTML += "<input type='button' value='メダル交換' onclick='game.getMedal(#{index})'>"
            slimeHTML += '</td>'
          else
            if index is composeId
              slimeHTML += "<input type='button' value='合成を終了' onclick='game.composeCansel(#{index})'>"
            else if slime.color is composeSlime.color and slime.rank is composeSlime.rank and slime.size < 1000
              slimeHTML += '</td><td>'
              slimeHTML += "<input type='button' value='素材にする(#{(status.slimes[composeId].size + status.slimes[index].size)}G)' onclick='game.composeStart(#{index})'>"
            slimeHTML += '</td>'
        slimeHTML += '</tr>'
      slimeHTML += '</table></form>'
      elementSlime.innerHTML = slimeHTML

  tax : ->
    pay = Math.floor(status.totalGold / 100) - status.tax
    if status.gold >= pay
      status.gold -= pay
      status.tax += pay
      status.growth += pay
    else
      status.tax += Math.floor(status.gold)
      status.growth += Math.floor(status.gold)
      status.gold -= Math.floor(status.gold)
    @setGrowthElement()
    @setSlimesElement()

  getMaxSlimes : -> Math.floor(Math.min(Math.max(50, status.bestSize / 40),100))

  getSlimes : (n) ->
    for i in [0...n]
      @getSlime()

  getSlime : ->
    return if status.gold < 300
    return if status.slimes.length >= @getMaxSlimes()
    status.gold -= 300
    slime = {
      color: Math.floor(Math.random() * 4)
      size:(Math.floor(Math.random() * 90) + 10)
      rank: 0
    }
    status.lastSlimeText = @getSlimeText(slime)
    console.log status.lastSlimeText
    status.slimes.push(slime)
    status.sortSlime()

    @setGrowthElement()
    @setSlimesElement()

  getMedal : (index) ->
    slime = status.slimes[index]
    console.log slime.rank
    console.log slime.color
    return unless slime.rank is 0
    return if slime.size < 1000
    status.medals[slime.color]++
    status.slimes.splice(index,1)
    save()
    @setGrowthElement()
    @setSlimesElement()

  compose : (index) ->
    return if status.growth < 20
    composeId = index
    @setGrowthElement()
    @setSlimesElement()

  autoComposeEquals : () ->
    return if status.slimes.length <= 1
    index = 0
    while index < status.slimes.length - 1
      index = 0
      while index < status.slimes.length - 1
        baseSlime = status.slimes[index]
        composeSlime = status.slimes[index + 1]
        if baseSlime.rank is composeSlime.rank is 0
          if baseSlime.color is composeSlime.color
            if baseSlime.size is composeSlime.size
              @compose(index)
              @composeStart(index + 1)
              @composeCansel()
              break
        ++index

  autoComposeNearby : (standardRate) ->
    return if status.slimes.length <= 1
    while true
      bestRate = 2.0
      bestIndex = -1
      for index in [0...status.slimes.length - 1]
        baseSlime = status.slimes[index]
        composeSlime = status.slimes[index + 1]
        if baseSlime.rank is composeSlime.rank is 0 and baseSlime.color is composeSlime.color and composeSlime.size < 1000
          rate = composeSlime.size / baseSlime.size
          if bestRate > rate
            bestRate = rate
            bestIndex = index
      console.log bestIndex + ',' + bestRate
      if bestRate <= (100 + standardRate) / 100
        if status.slimes[bestIndex].size + status.slimes[bestIndex + 1].size > status.gold
          break
        @compose(bestIndex)
        @composeStart(bestIndex + 1)
        @composeCansel()
      else
        break

  composeCansel : (index) ->
    composeId = -1
    status.sortSlime()
    @setGrowthElement()
    @setSlimesElement()

  composeStart : (index) ->
    size_first = status.slimes[composeId].size
    size_second = status.slimes[index].size

    pay = size_first + size_second
    return if status.slimes[index].rank != status.slimes[composeId].rank
    return if status.slimes[index].color != status.slimes[composeId].color
    return if status.gold < pay
    status.gold -= pay
    status.slimes[composeId].size = Math.floor(Math.sqrt(size_first * size_first + size_second * size_second))
    status.slimes.splice(index,1)
    --composeId if composeId > index

    @setGrowthElement()
    @setSlimesElement()

game = null
window.onload = ->
  game = new Game()
  game.init()
