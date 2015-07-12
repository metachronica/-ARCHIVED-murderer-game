/**
 * @author Viacheslav Lotsmanov <lotsmanov89@gmail.com>
 * @license GNU/AGPLv3
 * @see {@link https://www.gnu.org/licenses/agpl-3.0.txt|License}
 */

<- define

{head, tail} = require \prelude-ls

cbok = (cb)-> !->
	args =  Array::slice.call arguments
	err  =  args |> head ; throw err if err?
	args |> tail |> cb.apply null, _

cbcar = (car, cb)->
	<-! car
	args =  Array::slice.call arguments
	err  =  args |> head ; throw err if err?
	args |> tail |> cb.apply null, _

{cbok, cbcar}
