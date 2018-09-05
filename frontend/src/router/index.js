import Vue from 'vue';
import Router from 'vue-router';
Vue.use(Router);
const router = new Router({mode: 'history', base: '/', routes: [
		{path: '/', name: 'Home', component: () => import(/* webpackChunkName: "Home" */ '../pages/Home.vue')},
		{path: '/posts', name: 'Posts', component: () => import(/* webpackChunkName: "Posts" */ '../pages/Posts.vue')},
	]
});
export default router;
