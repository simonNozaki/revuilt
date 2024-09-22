<script lang="ts">
type ItemDetail = {
  id: number
  name: string
  price: number
  quantity: number
  tax_rate: string
}

type Data = {
  items: ItemDetail[]
}

export default {
  data(): Data {
    return {
      items: []
    }
  }
}
</script>

<template>
  <section>
    <h2>Item details</h2>
    <li>
      <ul v-for="item in items" :key="item.id"> {{ item.name }} {{ item.price | price }} </ul>
    </li>
  </section>
</template>
