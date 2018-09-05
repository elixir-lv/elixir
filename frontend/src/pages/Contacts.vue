<template>
	<default-layout>
		<contacts></contacts>
	</default-layout>
</template>
<script>
	import defaultLayout from '../layouts/Default.vue';
	import contacts from '../components/contacts.vue';
	export default {components: {defaultLayout, contacts}}
</script>
