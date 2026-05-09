import { Controller, Get } from '@nestjs/common'
import { ApiOkResponse, ApiTags } from '@nestjs/swagger'
import { Todo } from './todo.entity'
import type { TodoService } from './todo.service'

@ApiTags('todos')
@Controller('todos')
export class TodoController {
  constructor(private readonly todoService: TodoService) {}

  @Get()
  @ApiOkResponse({ type: Todo, isArray: true })
  findAll(): Todo[] {
    return this.todoService.findAll()
  }
}
