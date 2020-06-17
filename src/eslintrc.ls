export recommended =
  root: true,
  parser: '@typescript-eslint/parser',
  plugins: [
    '@typescript-eslint',
  ],
  extends: [
    'eslint:recommended',
    'plugin:@typescript-eslint/recommended',
  ]

export airbnbWithReact =
  root: true,
  parser: '@typescript-eslint/parser',
  plugins: [
    '@typescript-eslint',
  ],
  extends: [
    'airbnb-typescript',
  ]

export standard =
  extends: 'standard-with-typescript',
  parserOptions: {
    project: './tsconfig.json'
  }
  
export airbnbBase =
  extends: ['airbnb-typescript/base'],
  parserOptions: {
    project: './tsconfig.json',
  }