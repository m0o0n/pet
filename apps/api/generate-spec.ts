import { NestFactory } from '@nestjs/core'
import { DocumentBuilder, SwaggerModule } from '@nestjs/swagger'
import { existsSync, mkdirSync, writeFileSync } from 'fs'
import { dirname, join } from 'path'
import { AppModule } from './src/app.module'

async function generate() {
  const app = await NestFactory.create(AppModule, { logger: false })

  const config = new DocumentBuilder().setTitle('API').setVersion('1.0').build()
  const document = SwaggerModule.createDocument(app, config)

  const outputPath = join(__dirname, '../../generated/openapi.json')
  const outputDir = dirname(outputPath)

  if (!existsSync(outputDir)) {
    mkdirSync(outputDir, { recursive: true })
  }

  writeFileSync(outputPath, JSON.stringify(document, null, 2))

  await app.close()
  console.log('✓ openapi.json generated')
}

generate()
