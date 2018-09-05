import Vue from 'vue';
import Router from 'vue-router';
Vue.use(Router);
const router = new Router({mode: 'history', base: '/', routes: [
		{path: '/home', name: 'Home', component: () => import(/* webpackChunkName: "Home" */ '../pages/Home.vue')}]
});
export default router;
