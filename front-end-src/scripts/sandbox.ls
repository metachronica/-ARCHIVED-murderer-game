/**
 * @author Viacheslav Lotsmanov <lotsmanov89@gmail.com>
 * @license GNU/AGPLv3
 * @see {@link https://www.gnu.org/licenses/agpl-3.0.txt|License}
 */

(
	Promise, prelude, $
	cfg, R
) <- define <[
	promise prelude jquery
	cfg resource
]>

{
	map
	each
	obj-to-pairs
	pairs-to-obj
	take-while
	drop-while
	group-by
	tail
	replicate
	camelize
	reverse
	fold
	apply
	partition
} = prelude

load-res-elem = (res, elem) -->
	elem.0
		|> drop-while (isnt \.) # drop resource prefix
		|> tail # drop '.'
		|> res
		|> replicate 1 # wrap to list
		|> (++ (elem.1 |> camelize))
		|> reverse

parse-res-obj =
	(obj-to-pairs)
	>> (group-by (-> it.0 |> take-while (isnt \.))) # group by resource name
	>> (obj-to-pairs)
	>> (map -> it.1 |> map (load-res-elem R.get it.0))
	>> (fold (++), [])
	>> (pairs-to-obj)

class SandBox
	
	(module-name) !->
		
		@_$app  = cfg.$app
		@_$game = cfg.$game ? null
		
		@_bound-events = []
		@_bind-suffix = ".#{module-name}"
		
		@radio-on \game-block-initialized ($game) !~> @_$game = $game
	
	
	request-resource: (parse-res-obj)
	
	
	get-tpl-block: (tpl-name) -> $ "##{tpl-name}-tpl" .text! |> $
	put-tpl-block: ($tpl-block) !-> $tpl-block |> @_$game.html
	
	put-elems: ($block, obj) !-->
		obj
			|> obj-to-pairs
			|> each (!-> $block.find it.0 .get 0 |> it.1.append-to)
	
	
	# radio
	
	radio-on: (ev-name, cb) !->
		
		ev = "#{ev-name}#{@_bind-suffix}"
		fn = (e, ...params) !-> params |> apply cb
		
		@_bound-events.push [ ev, cb, fn ]
		
		@_$app.on ev, fn
	
	radio-once: (ev-name, cb) !->
		
		ev = "#{ev-name}#{@_bind-suffix}"
		fn = (e, ...params) !~>
			params |> apply cb
			@radio-off ev, cb
		
		@_bound-events.push [ ev, cb, fn ]
		
		@_$app.one ev, fn
	
	radio-off: (ev-name, cb) !->
		
		ev = "#{ev-name}#{@_bind-suffix}"
		
		lists = @_bound-events |> partition \
			if cb?
			then (-> (it.0 is ev) and (it.1 is cb))
			else (-> it.0 is ev)
		
		[@_$app.off ev, item.2 for item in lists.0]
		@_bound-events = lists.1
	
	radio-trigger: (ev-name, ...params) !->
		@_$app.trigger "#{ev-name}", params
