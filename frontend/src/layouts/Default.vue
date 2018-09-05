<template>
  <div>
		<div class="link-menu row">
			<div class="col s3">
					<a href="/">Home</a>
			</div>
			<div class="col s9 right">
				<ul>
						<li><a href="/posts">Posts</a></li>
						<li><a href="/contacts">Contacts</a></li>
						<li><a href="/map">Item in a map</a></li>
						<li><a href="/graphs">Graphs</a></li>
				</ul>
			</div>
		</div>
		<slot></slot>
  </div>
</template>
<script>
export default {name: 'default-layout'}
</script>
