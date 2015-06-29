/**
 * get current project version (git commit id)
 *
 * @author Viacheslav Lotsmanov <lotsmanov89@gmail.com>
 * @license GNU/AGPLv3
 * @see {@link https://www.gnu.org/licenses/agpl-3.0.txt|License}
 */

require! {
	\child_process : {spawn-sync}
}

res = spawn-sync \git, <[rev-parse HEAD]>

if res.status isnt 0 or not res.stdout? or res.stdout.to-string!.length <= 0
	throw new Error 'Cannot get head git commit id'

const git-head-id = res.stdout.to-string! - /\s/g

export revision = git-head-id
