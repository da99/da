
// =============================================================================
// == Time
// =============================================================================

function wait_max_seconds(seconds, func) {
    let max      = seconds * 1000;
    let current  = 0;
    let interval = 150;

    function reloop() {
      current = current + interval;
      if (func())
        return true;
      if (current >= max)
        throw new Error('Timeout exceeded: ' + DA.inspect(func) );
      else
        setTimeout(reloop, interval);
    }
    reloop();
};
