<script lang="ts">
export default {
  name: 'Message',
  props: {
    message: {
      type: String,
      required: true,
    }
  }
}
</script>

<template>
  <div>{{ message }}</div>
</template>
