<template>
	<default-layout>
		<posts></posts>
	</default-layout>
</template>
<script>
	import defaultLayout from '../layouts/Default.vue';
	import posts from '../components/posts.vue';
	export default {name: 'PostsPage', components: {defaultLayout, posts}}
</script>
