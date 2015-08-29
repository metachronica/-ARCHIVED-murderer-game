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

/**
 * input object:
 *   'resource-name.element-id': 'export-name'
 */
request-resource = (parse-res-obj)

{
	request-resource
	cfg
}
