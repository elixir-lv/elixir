<template>
	<default-layout>
		<post></post>
	</default-layout>
</template>
<script>
import defaultLayout from '../layouts/Default.vue';
import post from '../components/post.vue';
export default {name: 'PostPage',  components: {defaultLayout, post}}
</script>
