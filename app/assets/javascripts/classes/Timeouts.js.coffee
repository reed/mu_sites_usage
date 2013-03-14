class @Timeouts
  constructor: ->
    @timeouts = []
    
  add: (func, delay) =>
    @timeouts.push setTimeout(func, delay)

  clear: =>
    clearTimeout(timeout) for timeout in @timeouts
    @timeouts = []