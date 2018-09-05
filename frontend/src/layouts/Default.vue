<template>
  <div>
		<div class="row header">
			<div class="col s3 logo">
					<a href="/">Home</a>
			</div>
			<div class="col s6 link-menu ">
				<ul>
						<li><a href="/posts">Posts</a></li>
						<li><a href="/contacts">Contacts</a></li>
						<li><a href="/map">Item in a map</a></li>
						<li><a href="/graphs">Graphs</a></li>
				</ul>
			</div>
			<div class="col s3 right search">
					<form>
							<input class="search-input" type="text" placeholder="Seach...">
							<button type="submit">Search</button>
					</form>
			</div>
		</div>
		
		<slot></slot>
  </div>
</template>
<script>
export default {name: 'default-layout'}
</script>
